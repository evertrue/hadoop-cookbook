default['hadoop']['custom_libs'] = [
  {
    'delete_file' => '/lib/guava-11.0.2.jar',
    'new_file' => '/lib/guava-14.0.1.jar',
    'source' => 'http://search.maven.org/remotecontent?' \
      'filepath=com/google/guava/guava/14.0.1/guava-14.0.1.jar',
    'checksum' => 'd69df3331840605ef0e5fe4add60f2d28e870e3820937ea29f713d2035d9ab97'
  },
  {
    'delete_file' => '/lib/jackson-core-asl-1.8.8.jar',
    'new_file' => '/lib/jackson-core-asl-1.9.12.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/jackson-core-asl-1.9.12.jar',
    'checksum' => 'eb1fcba3554c8408fa40d17fb5d085ce1502d990c08940766e90d18801ad9c3a'
  },
  {
    'delete_file' => '/lib/jackson-jaxrs-1.8.8.jar',
    'new_file' => '/lib/jackson-jaxrs-1.9.12.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/jackson-jaxrs-1.9.12.jar',
    'checksum' => '401e6d16a19cef22deac363dcc2e7790707c2c19e0f1eb173172f09d9da33adb'
  },
  {
    'delete_file' => '/lib/jackson-mapper-asl-1.8.8.jar',
    'new_file' => '/lib/jackson-mapper-asl-1.9.12.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/jackson-mapper-asl-1.9.12.jar',
    'checksum' => '1a6d65351d7d7645719391e9336bd2f9296073b08eac082935d9b1650da351be'
  },
  {
    'delete_file' => '/lib/jackson-xc-1.8.8.jar',
    'new_file' => '/lib/jackson-xc-1.9.12.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/jackson-xc-1.9.12.jar',
    'checksum' => '63b43105cb043bf23e8e8302458ce5ffa67c70c514bb58f89da2855f410d2f61'
  },
  {
    'new_file' => '/lib/mysql-connector-java-5.1.24.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/mysql-connector-java-5.1.24.jar',
    'checksum' => 'f4349b4f3770fabc8eda03b86015edb3cf07b19009c97158b64ebba45c2cb4ba'
  },
  {
    'delete_file' => '/lib/snappy-java-1.0.4.1.jar',
    'new_file' => '/lib/snappy-java-1.1.0.1.jar',
    'source' => 'http://central.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.0.1/snappy-java-1.1.0.1.jar',
    'checksum' => '563eacba41f76f5dc086afe2cfca60ec1c961b70b69f1e94d7b34740dc3e3af5'
  }
]
