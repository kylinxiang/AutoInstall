# -*- coding: UTF-8 -*-
import sys
import os
import xlrd
import subprocess
from get_mmt_port import create_env_file, modify_para, CFG_PATH

dict_Test_line = {}


class TestLine:
    def __init__(self, TM500_IP, TM500_Type, BTS_IP, DCT_IP, RNC_IP, RNC_Type):
        self.TM500_IP = TM500_IP
        self.TM500_Type = TM500_Type
        self.BTS_IP = BTS_IP
        self.DCT_IP = DCT_IP
        self.RNC_IP = RNC_IP
        self.RNC_Type = RNC_Type


def loadXls(file, bts_ip):
    workbook = xlrd.open_workbook(file)
    sheet = workbook.sheets()[1]
    nrows = sheet.nrows

    i = filter(lambda x: bts_ip == sheet.cell(x, 6).value.strip(), range(2, nrows))[0]
    TM500_IP = sheet.cell(i, 1).value.strip()
    TM500_Type = sheet.cell(i, 2).value.strip()
    BTS_IP = bts_ip
    # if bts control pc is win xp, then dct is install on the same pc, info about dct ip
    # in xls file is None
    dct_ip = sheet.cell(i, 7).value.strip()
    DCT_IP = dct_ip if dct_ip else bts_ip
    rnc_ip_port = sheet.cell(i, 18).value.strip().split('-')
    RNC_IP = rnc_ip_port[0]
    RNC_Type = sheet.cell(i, 19).value.strip()

    dict_Test_line[BTS_IP] = TestLine(TM500_IP, TM500_Type, BTS_IP, DCT_IP, RNC_IP, RNC_Type)

    # config para
    modify_para('CFG_BTS_FACOM_IP', sheet.cell(i, 10).value.strip().split('-')[0])
    modify_para('CFG_BTS_FACOM_PORT', sheet.cell(i, 10).value.strip().split('-')[1][4:])
    modify_para('CFG_BTS_ControlPC_IP', bts_ip)
    iub_src = sheet.cell(i, 9).value.strip()
    iub_dst = sheet.cell(i, 17).value.strip()
    modify_para('CFG_IuB_SrcIP', iub_src)
    modify_para('CFG_IuB_DestIP', iub_dst)
    iub_f1 = lambda i: modify_para('CFG_IuB_SrcIP_Single_%d' % i, iub_src.split('.')[-i])
    map(iub_f1, range(1, 5))
    iub_f2 = lambda i: modify_para('CFG_IuB_DestIP_Single_%d' % i, iub_dst.split('.')[-i])
    map(iub_f2, range(1, 5))
    modify_para('CFG_RNCSIM_DeviceType', sheet.cell(i, 19).value.strip())
    modify_para('CFG_RNCSIM_ControlPC_IP', RNC_IP)
    if len(rnc_ip_port) > 1:
        modify_para('CFG_RNCSIM_Slot_Port', '505' + rnc_ip_port[1][4:])
    modify_para('CFG_TM500_ControlPC_IP', TM500_IP)
    modify_para('CFG_TM500_Type', TM500_Type)
    modify_para('CFG_DCT_IP', DCT_IP)


def call_line_rdp(bts_ip):
    # put bts to the last for svn checkout need other device para info
    dev_line = ['TM500', 'RNC', 'DCT', 'BTS']
    for dev in dev_line:
        ip = getattr(dict_Test_line[bts_ip], '%s_IP' % dev)
        dev_t = 'null'
        try:
            dev_t = getattr(dict_Test_line[bts_ip], '%s_Type' % dev)
        except AttributeError:
            pass
        cmd = "rdp.exe %s %s %s" % (ip, dev, dev_t)
        print "Call: ", cmd
        result = os.system(cmd)
        if result == 1:
            print "install %s success! IP = %s" % (dev, ip)
        else:
            print "install %s fail! IP = %s" % (dev, ip)


def checkout_line_rdp(bts_ip):
    file_to_commit = os.path.join(CFG_PATH, 'bts_%s_env.txt' % bts_ip)
    subprocess.call('svn add --username ziqli --password Tp312ja05i %s' % file_to_commit)
    subprocess.call('svn commit --username ziqli --password Tp312ja05i %s -m "add env file for %s"'
                    % (file_to_commit, bts_ip))


if __name__ == '__main__':
    '''
    Test Case:
        Test line:
            python AutoInstall.py line 10.69.6.23
            python AutoInstall.py line 10.69.6.23 10.69.6.39 10.69.7.11
    '''
    if sys.argv[1] == "line":
        for i in range(2, len(sys.argv)):
            bts_ip = sys.argv[i]
            create_env_file(bts_ip)
            loadXls('LRC minicfg env HW info.xlsx', bts_ip)
            call_line_rdp(bts_ip)
            checkout_line_rdp(bts_ip)
    else:
        print "Input Error!"
