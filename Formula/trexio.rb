class Trexio < Formula
  desc "TREX I/O library"
  homepage "https://trex-coe.github.io/trexio/"
  url "https://github.com/TREX-CoE/trexio/releases/download/v2.1.0/trexio-2.1.0.tar.gz"
  sha256 "232866c943b98fa8a42d34b55e940f7501634eb5bd426555ba970f5c09775e83"
  license "BSD-3-Clause"
  head "https://github.com/TREX-CoE/trexio.git", branch: "master"
  # This cask will not be merged in the upstream homebrew due to the following reason (from `brew audit`)
  #   * GitHub repository not notable enough (<30 forks, <30 watchers and <75 stars)
  # (see https://github.com/Homebrew/brew/blob/master/docs/Acceptable-Formulae.md)

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "hdf5"

  def install
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <assert.h>
      #include "trexio.h"
      int main()
      {
        printf("%10s\\n", TREXIO_PACKAGE_VERSION);

        trexio_exit_code rc = TREXIO_FAILURE;
        trexio_t* test_file = NULL;

        test_file = trexio_open("brew_test.dir", 'w', TREXIO_TEXT, &rc);
        assert(test_file != NULL);
        assert(rc == TREXIO_SUCCESS);

        rc = trexio_write_nucleus_num(test_file, 666);
        assert(rc == TREXIO_SUCCESS);

        rc = trexio_close(test_file);
        assert(rc == TREXIO_SUCCESS);

        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ltrexio", "-o", "test"
    system "./test"
    assert_predicate testpath/"brew_test.dir"/"nucleus.txt", :exist?
  end
end
