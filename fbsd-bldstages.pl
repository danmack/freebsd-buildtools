# things to record timing on during a build

# this datastructure directs the program to record the first timestamp
# when this string appears in a log file; these are the default FreeBSD
# build stages, but you can add any pattern (e.g. start of clang build,
# end of clang build) or whatever you are interested in

# these should be entered in order that they will be generated, if
# this changes over time, then simply create a new SVN id hash key
# section to accomodate the change

%stages = (
    'buildworld' => {
        'default' => [
            '>>> World build started',
            '>>> Rebuilding the temporary build tree',
            '>>> stage 1.1: legacy release compatibility shims',
            '>>> stage 1.2: bootstrap tools',
            '>>> stage 2.1: cleaning up the object tree',
            '>>> stage 2.2: rebuilding the object tree',
            '>>> stage 2.3: build tools',
            '>>> stage 3: cross tools',
            '>>> stage 3.1: recording compiler metadata',
            '>>> stage 4.1: building includes',
            '>>> stage 4.2: building libraries',
            '>>> stage 4.3: building everything',
            '>>> stage 5.1: building lib32 shim libraries',
            '>>> World build completed'
        ],
        '400000' => [
            '>>> World build started',
            '>>> Rebuilding the temporary build tree',
            '>>> stage 1.1: legacy release compatibility shims',
            '>>> stage 1.2: bootstrap tools',
            '>>> stage 2.1: cleaning up the object tree',
            '>>> stage 2.2: rebuilding the object tree',
            '>>> stage 2.3: build tools',
            '>>> stage 3: cross tools',
            '>>> stage 3.1: recording compiler metadata',
            '>>> stage 4.1: building includes',
            '>>> stage 4.2: building libraries',
            '>>> stage 4.3: building everything',
            '>>> stage 5.1: building lib32 shim libraries',
            '>>> World build completed'
        ],
    },
    'buildkernel' => {
        'default' => [
            '>>> Kernel build for GENERIC started',
            '>>> stage 1: configuring the kernel',
            '>>> stage 2.1: cleaning up the object tree',
            '>>> stage 2.2: rebuilding the object tree',
            '>>> stage 2.3: build tools',
            '>>> stage 3.1: building everything',
            '>>> Kernel build for GENERIC completed'
            ],
        '400000' => [
            'start',
            'end',
            ],
    },
    'installkernel' => {
        'default' => [
            '>>> Installing kernel GENERIC',
            'kldxref /boot/kernel'
            ],
        '400000' => [
            'start',
            'end',
            ],
    },
    );

1;
