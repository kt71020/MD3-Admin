use strict;
use warnings;
use FindBin;
use File::Slurp;

use lib "/Users/kt/kcode/docker/maintenance/lib";
my $version_path = $FindBin::Bin . "/Version";
use Maintenance;
my $main = new Maintenance();

print "ordTa API 開發環境 製作印象\n";
print "目前路徑：$FindBin::Bin\n";

my $ver_base_path   = $version_path . '/base.ver';                                             # base 檔案路徑
my $ver_dev_path    = $version_path . '/dev.ver';                                              # dev 檔案路徑
my $base_version    = $main->get_version($ver_base_path);                                      # base 取得版號
my $dev_version     = $main->get_version_plus($ver_dev_path);                                  # dev+1 取得版號
my $dockerfile_path = $FindBin::Bin . '/../Dockerfile/development.Dockerfile';                 # base 檔案路徑
my $replace_name    = $FindBin::Bin . '/../Dockerfile/dev-' . $dev_version . '.Dockerfile';    # base 檔案路徑
my $image_name      = "ordta-dev";                                                             # image 名稱
my $dev_path        = "/Users/kt/kcode/perl/ordTa";                                            # 開發環境路徑

$main->replace_version( $dockerfile_path, $replace_name, $base_version );                      # 取代 base 版本

system( "docker build --platform=linux/amd64 -t " . $image_name . ":" . $dev_version . " -f " . $replace_name . " . " );
$main->set_version( $ver_dev_path, $dev_version );

unlink $replace_name;                                                                          # 刪除檔案
print " 將開發環境建立\n";
print " docker run -d -p 8033:22 -p 5120:5000 -v " . $dev_path . ":/app " . $image_name . ":" . $dev_version . "\n";

