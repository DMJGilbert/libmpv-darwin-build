# https://mesonbuild.com/External-Project-module.html

project('libsrt', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--enable-static=0',
        '--enable-shared=1',
        '--enable-apps=0',
        '--use-enclib=mbedtls',
        '--disable-test',
    ],
    verbose: true,
)

libsrt_dep = p.dependency('libsrt')
meson.override_dependency('libsrt', libsrt_dep)
