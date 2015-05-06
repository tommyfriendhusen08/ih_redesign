class AWSBuckets
  def AWSBuckets.create_unless_exists!(s3, bucket_name)
    bucket = s3::Bucket.new(bucket_name)
    unless bucket.exists?
      s3.new.buckets.create(bucket_name)
    end
  end
end
