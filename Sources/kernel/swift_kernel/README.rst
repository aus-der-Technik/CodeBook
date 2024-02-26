swift_kernel
===========

``swift_kernel`` is a simple Jupyter kernel. This repository
is based on the documentation on wrapper kernels here:

http://jupyter-client.readthedocs.io/en/latest/wrapperkernels.html

Installation
------------

From PyPI
~~~~~~~~~

To install ``swift_kernel`` from PyPI::

    pip3 install swift_kernel

From Git using Conda
~~~~~~~~~~~~~~~~~~~~

To install ``swift_kernel`` from git into a Conda environment::

    git clone https://github.com/petershaw/swift_kernel
    cd swift_kernel
    conda create -n ker jupyter
    conda activate ker
    pip install .


Using the Swift kernel
---------------------
**Notebook**: The *New* menu in the notebook should show an option for an Swift notebook.

**Console frontends**: To use it with the console frontends, add ``--kernel swift`` to
their command line arguments.
