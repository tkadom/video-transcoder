class Video < ActiveRecord::Base
  include AASM
  aasm_column :status
  aasm_initial_state :initial
  
  aasm_state :initial
  aasm_state :converting, :exit => :transcode
  aasm_state :transfering , :exit => :send_s3
  aasm_state :completed
  aasm_state :failed
  
  aasm_event :convert do
    transitions :from => [:initial], :to => :converting
  end
  
  aasm_event :transfer do
    transitions :from => [:converting], :to => :transfering
  end
  
  aasm_event :complete do
    transitions :from => [:transfering], :to => :completed
  end
  
  aasm_event :error do
    transitions :from => [:initial, :converting, :transfering, :completed], :to => :error
  end

  has_attached_file :asset, 
    :path => "uploads/:attachment/:id.:basename.:extension"

  def flash_path
    return self.asset.path + '.flv'
  end
  
  def flash_name
    return File::basename(self.asset.path + '.flv')
  end

   def flash_url
     return "#{AWS_HOST}/#{AWS_BUCKET}/#{self.flash_name}"
   end

  # transcode file
  def transcode
    begin
      RVideo::Transcoder.logger = logger
      file = RVideo::Inspector.new(:file => self.asset.path)
      command = "ffmpeg -i $input_file$ -y -s $resolution$ -ar 44100 -b 64k -r 15 -sameq $output_file$"
      options = {
        :input_file => "#{RAILS_ROOT}/#{self.asset.path}",
        :output_file => "#{RAILS_ROOT}/#{self.flash_path}",
        :resolution => "320x200" 
      }
      transcoder = RVideo::Transcoder.new
      transcoder.execute(command, options)
      rescue RVideo::TranscoderError => e
        logger.error "Encountered error transcoding #{self.asset.path}"
        logger.error e.message
      end
  end
 
  # send file to s3
  def send_s3
    begin
      @s3 ||= RightAws::S3.new(AWS_ACCESS_KEY, AWS_SECRET_KEY)
      @bucket ||= @s3.bucket(AWS_BUCKET, true, 'public-read')
      newkey = RightAws::S3::Key.create(@bucket, self.flash_name)
      newkey.put(File.open(self.flash_path), 'public-read')
      return true
    rescue RightAws::AwsError => e
      logger.error "Error in uploading to S3 for #{self.flash_path}:" +  e.message
      return false
    end
  end

  def process!
    begin
      if self.convert! && self.transfer! && self.complete!  
        logger.info "Completed #{self.asset.path}"
      else
        logger.error "Encountered error with #{self.asset.path}"
        self.error!
      end
    rescue Exception => e
      logger.error "Encountered error uploading #{self.asset.path}"
      logger.error e.message
    end
  end

end
