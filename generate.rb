class Generate < Struct.new :data
  def generate text
    data.each { |k, v|
      text = text.sub /#{k}=.*"/, %'#{k}=#{v}"'
    }
    text
  end

  # ...
  def degenerate text
    data.each { |k, v|
      text = text.sub /#{k}=.*"/, %'#{k}=GENERATED"'
    }
    text
  end
end

if __FILE__ == $0
  text = <<~END
    ...
    Environment="BucketName=GENERATED"
    Environment="AccessKeyId=GENERATED"
    Environment="SecretAccessKey=GENERATED"
    ...
  END

  data = {
    'BucketName' => ?1,
    'AccessKeyId' => ?2,
    'SecretAccessKey' => ?3,
  }

  g = Generate.new data
  got = g.generate text

  raise unless got ==
  <<~END
    ...
    Environment="BucketName=1"
    Environment="AccessKeyId=2"
    Environment="SecretAccessKey=3"
    ...
  END

  raise unless g.degenerate(got) == text
end
