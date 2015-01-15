# Upload 

require_relative 's3_upload'

bucket_name = 'gitkitty.com'
dir_name = '_site'

S3FolderUpload.new(dir_name, bucket_name).upload!
