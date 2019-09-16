require File.expand_path("../Strategies/cache_wo_download", __dir__)

# A formula that installs the Instant Client SDK package.
class InstantclientSdk < Formula
  desc "Oracle Instant Client SDK x64"
  homepage "https://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  hp = homepage

  url "https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-sdk-macos.x64-19.3.0.0.0dbru.zip",
      :using => (Class.new(CacheWoDownloadStrategy) do
                   define_method :homepage do
                     hp
                   end
                 end)
  sha256 "b46b4b87af593f7cfe447cfb903d1ae5073cec34049143ad8cdc9f3e78b23b27"

  def install
    lib.install ["sdk"]
    # Header files can not be moved out of sdk/include because some software
    # (e.g. ruby-oci8) expects to find them there. Link the header files
    # instead.
    Dir[lib.join("sdk/include/*.h")].each do |header_file|
      include.install_symlink header_file
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <oci.h>

      int main()
      {
        ub4 od = OCI_DEFAULT;
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-o", "test"
    system "./test"
  end
end
