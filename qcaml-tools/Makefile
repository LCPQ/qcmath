# Frontend to dune.
.NOTPARALLEL:

TARGETS=qcmath_input \
        qcmath_integrals \
        GoMath

.PHONY: default build install uninstall test clean

default: $(TARGETS)
	mv GoMath ../

%.exe: build
	dune build $@

$(TARGETS): $(patsubst %, %.exe, $(TARGETS))
	for i in $(TARGETS) ; do cp _build/default/$${i}.exe $$i ; done

build:
	dune build

clean:
	dune clean


