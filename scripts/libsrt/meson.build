# https://mesonbuild.com/External-Project-module.html

project('libsrt', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-shared',
        '--use-enclib=mbedtls',
    ],
    verbose: true,
)

libsrt_dep = p.dependency('libsrt')
meson.override_dependency('libsrt', libsrt_dep)
