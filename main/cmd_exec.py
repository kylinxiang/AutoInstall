from tempfile import TemporaryFile
import subprocess
import telnetlib
import re


def execute_cmd(cmd):
    with TemporaryFile() as fp_o, TemporaryFile() as fp_e:
        rt = subprocess.call(cmd, stdout=fp_o, stderr=fp_e, shell=True)
        if fp_e.tell():
            fp_e.seek(0)
            raise Exception("executed cmd is:%s\nthe error_info is:%s" % (cmd, fp_e.read()))
        fp_o.seek(0)
        return fp_o.read()


def do_telnet(Host, commands, username='upl1-tester', password='btstest', finish='C:\\>'):
    tn = telnetlib.Telnet(Host)
    tn.read_until('Login username:')
    tn.write(username + '\r\n')
    tn.read_until('Login password:')
    tn.write(password + '\r\n')
    tn.read_until('Domain name:')
    tn.write('\r\n')
    tn.read_until(finish)
    for command in commands:
        tn.write('%s\r\n' % command)
        tn.read_until('>')
    tn.write("exit\r\n")
    tn.close()


def get_lab_interface():
    get_intf_ip = 'ipconfig'
    ip_info = execute_cmd(get_intf_ip)
    prog = re.compile('.*IP(v4)?.*?(10\.69(\.[0-9]+){2})', re.DOTALL)
    lab_ip = prog.match(ip_info).groups()[1]
    return lab_ip


def get_rdp_ip():
    get_ip_cmd = 'netstat -anp tcp|find "%s:3389"|find "ESTABLISHED"' % get_lab_interface()
    ip_info = execute_cmd(get_ip_cmd)
    prog = re.compile('.*(10(\.[0-9]+){3})', re.DOTALL)
    rdp_ip = prog.match(ip_info).groups()[0]
    return rdp_ip

def deal_svn_cert(cmd):
    # not stable, sometimes won't work for unknown reason
    # change repo url from https to http
    # p = subprocess.Popen("echo t |", shell=True,
    # stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    # p1 = subprocess.Popen(cmd, shell=True,
    # stdin=p.stdout, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    p1 = subprocess.Popen(cmd, shell=True).communicate()
    output = p1[0]
    print output


def do_svn_checkout(cmd):
    ip_data = get_lab_interface()
    host = get_rdp_ip()
    commands = ['cd Users\upl1-tester', 'echo succeed > checkout_succeed.txt', 'cd Autoinstall_Status',
                'echo %s >> checkout_status.txt' % ip_data]

    deal_svn_cert(cmd)
    do_telnet(host, commands)
