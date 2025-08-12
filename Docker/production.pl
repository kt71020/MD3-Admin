use strict;
use warnings;
use FindBin;

use lib "/Users/kt/kcode/docker/maintenance/lib";
my $version_path = $FindBin::Bin . "/Version";
use Maintenance;
my $main = new Maintenance();

print "Must Dine 3 API 正式環境 製作印象\n";

my $ver_base_path       = $version_path . '/base.ver';                               # base 檔案路徑
my $ver_production_path = $version_path . '/production.ver';                         # dev 檔案路徑
my $base_version        = $main->get_version($ver_base_path);                        # base 取得版號
my $production_version  = $main->get_version_plus($ver_production_path);             #  取得版號
my $dockerfile_path     = $FindBin::Bin . '/../Dockerfile/production.Dockerfile';    # 檔案路徑
my $replace_name        = $FindBin::Bin . '/../Dockerfile/production-' . $production_version . '.Dockerfile';    #  檔案路徑

# Image naming (can be overridden via environment variables)
my $image_namespace = $ENV{'IMAGE_NAMESPACE'} // 'kt71020';      # e.g. Docker Hub username/org
my $image_name_base = $ENV{'IMAGE_NAME_BASE'} // 'md3-admin';    # repo name for base image

$main->replace_version( $dockerfile_path, $replace_name, $base_version );    # 取代 base 版本

# Build image
print("Base Version : $base_version\n");
print("Production Version : $production_version\n");

system( "cd $FindBin::Bin/.. && docker build --no-cache  --platform=linux/amd64 -t "
      . $image_namespace . "/"
      . $image_name_base . ":"
      . $production_version . " -f "
      . $replace_name
      . ' --build-arg CACHEBUST=$(date +%s) .' );

system( "docker push " . $image_namespace . "/" . $image_name_base . ":" . $production_version );

unlink $replace_name;
$main->set_version( $ver_production_path, $production_version );
