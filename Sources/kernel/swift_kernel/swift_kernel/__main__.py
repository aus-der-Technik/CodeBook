from ipykernel.kernelapp import IPKernelApp
from . import SwiftKernel

IPKernelApp.launch_instance(kernel_class=SwiftKernel)
