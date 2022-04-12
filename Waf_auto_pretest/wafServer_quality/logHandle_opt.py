#!/usr/bin/python2.7
#coding=utf-8

import pandas as pd
import json
import os
import time
import sys
import logging
import commands


logging.basicConfig(filename = "/usr/local/waf_test/logs/waf_test.log",level = logging.INFO, filemode = 'a', format = '%(asctime)s - %(levelname)s: %(message)s')


if __name__ == '__main__':
    # 获取压测版本
    mode = sys.argv[1]
    baseline_version = sys.argv[2]
    waf_version = sys.argv[3]
    data_version = sys.argv[4]
    operation = sys.argv[5]
    guid = sys.argv[6]

    # 获取对应版本的路径，文件需要放的位置
    if operation == "0":
        path = '/usr/local/waf_test/baseline/' + waf_version + '-' + data_version + '-' + mode
    else:
        path = '/usr/local/waf_test/analysis/' + guid + '-' + mode

    errorDic = {}  # 按域名存储错误日志
    total_dic = {}  # 按域名存储状态码信息
    format_error = []
    header = ['wafStatus', 'original_status', 'channel']
    total = ['400', '403', '408', '499', '500', '502', '503']

    while True:
        res = []
        if os.path.exists('/usr/local/nginx/logs/access/access.log') and os.path.getsize('/usr/local/nginx/logs/access/access.log'):
            # 拉取日志
            try:
                os.system('rm -f /usr/local/waf_test/tmp/tmp/*')
                os.system('mv /usr/local/nginx/logs/access/access.log /usr/local/waf_test/tmp/tmp/access.log')
                print('拉取日志成功')
            except Exception as msg:
                logging.error(str(msg))

            # 通知进程重新产生日志
            count = 0
            while count < 3:
                _, pID = commands.getstatusoutput('cat /usr/local/nginx/logs/nginx.pid')
                os.system('kill -s USR1 ' + pID)
                time.sleep(5)
                if os.path.exists('/usr/local/nginx/logs/access/access.log'):
                    print('access.log regenerate succeed')
                    break
                count += 1
            if count == 3:
		print('access.log regenerate failed')
                logging.error('access.log regenerate failed')

            # 对本次拉取的日志进行分析
            with open("/usr/local/waf_test/tmp/tmp/access.log", "r") as f:
                for line in f:
                    if line.find('pepp4_') == -1:
                        try:
                            lineList = []
                            index1 = line.index('HTTP/')
                            index2 = line[index1 + 10:].index(' ')
                            Li = line[index1:index1 + 10 + index2].split()
                            index3 = line.index('WAF_')
                            li = line[index3:].split()
                            # 保存异常状态的日志信息，按域名分类
                            if li[5] == '-' and Li[1] in total:
                                lineList.append(Li[1])
                                lineList.append(li[5])
                                lineList.append(li[6])
                                res.append(lineList)
                                if lineList[2] in errorDic:
                                    errorDic[lineList[2]].append(line)
                                else:
                                    errorDic.setdefault(lineList[2], [line])
                        except (Exception, ValueError):
                            format_error.append(line)

            pf = pd.DataFrame(res, columns=header)
            typeList = pf['channel'].unique()
            # 生成所有状态码统计文件
            if len(pf) > 0:
                for Type in typeList:
                    pf_ii = pf[pf['channel'].isin([Type])]
                    Se = pf_ii['wafStatus'].value_counts()
                    statusCode = eval(Se.to_json())
                    # 合并域名相同的状态码数量
                    if Type in total_dic:
                        for key in statusCode:
                            if key in total_dic[Type]:
                                total_dic[Type][key] += statusCode[key]
                            else:
                                total_dic[Type][key] = statusCode[key]
                    else:
                        total_dic[Type] = statusCode

            # 获取时间戳
            time_tup = time.localtime(time.time())
            format_time = '%Y%m%d%H%M%S'
            dateStamp = time.strftime(format_time, time_tup)
            if operation == "0":
                os.system('mv /usr/local/waf_test/tmp/tmp/access.log /usr/local/waf_test/tmp/' + waf_version + '-' + data_version + '-' + mode + '/bak/access.log.' + dateStamp)
            else:
                os.system('mv /usr/local/waf_test/tmp/tmp/access.log /usr/local/waf_test/tmp/' + guid + '-' + mode + '/bak/access.log.' + dateStamp)

	    # 获取CPU及MEM,传参为测试类别和测试版本
            os.system('sh /usr/local/waf_test/sbin/gainCpuMem.sh' + ' ' + mode + ' ' + baseline_version + ' ' + waf_version + ' ' + data_version + ' ' + operation + ' ' + guid)


        # 程序结束的标志
        if os.path.exists('/usr/local/waf_test/tmp/signal') and not os.path.getsize('/usr/local/nginx/logs/access/access.log'):
            break

        # 每隔一分钟取一次日志
        print('sleep一分钟')
        time.sleep(60)

    # 按域名记录所有异常日志
    if operation == "0":
        pa = '/usr/local/waf_test/tmp/' + baseline_version+'-'+data_version+'-'+mode
    else:
        pa = '/usr/local/waf_test/tmp/' + guid + '-' + mode
    for key in errorDic:
        with open(pa + '/error_status/' + key, 'w') as fp:
            for error in errorDic[key]:
                fp.write(error)
    print('异常日志记录成功')

    # 按域名记录状态码信息
    with open(path + '/totalData.json', 'w') as f:
        f.write(json.dumps(total_dic, indent=2) + '\n')
    print('状态码记录成功')

    # 记录格式错误的日志信息
    with open(path + '/format_error.log', 'w')as fp:
        for log in format_error:
            fp.write(log)
    print('格式错误日志记录成功')
