from ipykernel.kernelbase import Kernel
import pexpect
import re

class SwiftKernel(Kernel):
    implementation = 'Swift'
    implementation_version = '1.0'
    language = 'swift'
    language_version = '5.8'
    language_info = {
        'name': 'swift',
        'mimetype': 'text/plain',
        'file_extension': '.swift',
    }
    banner = "Swift Kernel"
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        log = open("/var/log/swiftkernel.log", 'a')
        self.c = pexpect.spawnu('swift repl -no-color-diagnostics -suppress-warnings', echo=False, encoding="utf-8", logfile=log)
        self.c.expect(r"\s+[0-9]+\>(.*)", re.MULTILINE)
        
    def do_execute(self, code, silent, store_history=False, user_expressions=None,
                   allow_stdin=False):

        if not silent:
            bytes_written = self.c.sendline(code)
            self.c.sendline('"EOL"')
            self.c.expect_exact('String = "EOL"')

            output = self.c.before
            output_lines = output.split("\r\n")
            
            filtered = filter(None, [re.sub(r"\s+[0-9]+(\>|\.)\s+.+", "___EMPTY___", i) for i in output_lines])
            filtered = list(filtered)[1:][:-2]

            output = "\r\n".join(x for x in filtered if '___EMPTY___' not in x)
            
            stream_content = {'name': "stdout", 'text': output}
            self.send_response(self.iopub_socket, 'stream', stream_content)
        
        return {'status': 'ok',
                # The base class increments the execution count
                'execution_count': self.execution_count,
                'payload': [],
                'user_expressions': {},
                }

    def do_shutdown(self):
        self.c.close()
