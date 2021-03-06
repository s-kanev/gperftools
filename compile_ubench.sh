#!/bin/bash

MAGIC=no
OUTPUT_DIR=output_${MAGIC}

UB="tp tp_dep gauss gauss_free prod tp_small sized_deletes antagonist"
mkdir -p ${OUTPUT_DIR}

# rm -rf fdo_build*
# mkdir fdo_build
# cd fdo_build

cd build

./do_configure.sh no ${MAGIC} || exit 1
make -j24 || exit 1

for BMK in ${UB}
do
  cp ${BMK} ../${OUTPUT_DIR}/
  cp ${BMK}_native ../${OUTPUT_DIR}/
done

cd ..

# Don't do FDO builds - reusing profiles for new magic instructions is
# nontrivial.
exit 0

# For FDO.
# yeah, this is ugly, but seems to be the only way
# to pass the right profiles for libtcmalloc, not just
# the bmk wrapper

for BMK in ${UB}
do
    BUILD_DIR=fdo_build_${BMK}
    mkdir $BUILD_DIR
    cd $BUILD_DIR
    ln -s ../fdo_build/${BMK} ${BMK}
    ./${BMK}

    echo "Compiling opt for ${BMK}..."
    ../build/do_configure.sh optimize list_magic || exit 1
    make -j24 || exit 1

    cp ${BMK} ../${OUTPUT_DIR}/
    cp ${BMK}_native ../${OUTPUT_DIR}/

    cd ..
done
