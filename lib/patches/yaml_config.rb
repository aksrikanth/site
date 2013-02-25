YAML.class_eval do

  def self.load_configuration(file_name)
    file_name = find_file!(file_name)
    config  = load_file(file_name)[Rails.env]
    if config.nil?
      raise "Configuration file '#{File.basename(file_name)}' has no entry for environment #{Rails.env}"
    end
    HashWithIndifferentAccess.new(config)
  end

private

  def self.find_file!(file_name)
    file_name = Rails.root.join(file_name) unless File.exists?(file_name)
    file_name = File.expand_path(file_name)
    raise "Cannot find configuration file '#{File.basename(file_name)}'" unless File.exists?(file_name)
    return file_name
  end

end
