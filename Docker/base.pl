use strict;
use warnings;
use FindBin;
use lib "/Users/kt/kcode/docker/maintenance/lib";
my $version_path = $FindBin::Bin . "/Version";
use Maintenance;
my $main = new Maintenance();

print "系統開發 製作 MD3 Admin 基礎印象\n";
my $ver_path          = $version_path . '/base.ver';                                   # base 檔案路徑
my $dockerfile_path   = $FindBin::Bin . '/../Dockerfile/md3_admin_base.Dockerfile';    # base 檔案路徑
my $base_version      = $main->get_version($ver_path);                                 # base 取得版號
my $base_version_plus = $main->get_version_plus($ver_path);                            # base 取得版號

# Image naming (can be overridden via environment variables)
my $image_namespace = $ENV{'IMAGE_NAMESPACE'} // 'kt71020';                            # e.g. Docker Hub username/org
my $image_name_base = $ENV{'IMAGE_NAME_BASE'} // 'md3-admin-base';                     # repo name for base image
my $image_name_mac  = $ENV{'IMAGE_NAME_MAC'}  // 'md3-admin-base-mac';                 # repo name for mac image

# Build image（使用專案根目錄作為 Build Context，讓 Dockerfile 內的 COPY Docker/nginx/nginx.conf 成立）
system( "cd $FindBin::Bin/.. && docker build --push --platform=linux/amd64 -t "
      . $image_namespace . "/"
      . $image_name_base . ":"
      . $base_version_plus . " -f "
      . $dockerfile_path
      . " . " );
system( "cd $FindBin::Bin/.. && docker build --push -t "
      . $image_namespace . "/"
      . $image_name_mac . ":"
      . $base_version_plus . " -f "
      . $dockerfile_path
      . " . " );
$main->set_version( $ver_path, $base_version_plus );

#  docker build -t perl:base -f base.Dockerfile .
#  docker tag perl:base kt71020/perl:api-assetbook-0.1.1
#  docker push kt71020/perl:api-assetbook-0.1.1
