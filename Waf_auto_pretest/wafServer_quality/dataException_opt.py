#!/usr/bin/python2.7
#coding=utf-8


from __future__ import division
import json
import sys
import logging
import os

logging.basicConfig(filename = "/usr/local/waf_test/logs/waf_test.log",level = logging.INFO, filemode = 'a', format = '%(asctime)s - %(levelname)s: %(message)s')


if __name__ == '__main__':
    mode = sys.argv[1]
    baseline_version = sys.argv[2]
    waf_version = sys.argv[3]
    data_version = sys.argv[4]
    operation = sys.argv[5]
    guid = sys.argv[6]
    # 获取对应版本的路径，获取文件的位置
    baselinePath = '/usr/local/waf_test/baseline/' + baseline_version+'-'+data_version+'-'+mode
    testPath = '/usr/local/waf_test/analysis/' + guid + '-' + mode

    dic_normal = {}
    dic_test = {}
    # 基准版
    try:
        with open(baselinePath + "/totalData.json", "r") as f:
            dic_normal = json.load(f)
    except IOError as msg:
        logging.error(str(msg))
    # 测试版
    try:
        with open(testPath + "/totalData.json", "r") as fp:
            dic_test = json.load(fp)
    except IOError as msg:
        logging.error(str(msg))

    total_dic = {}
    with open(testPath + '/report.txt', 'a+') as fp:
        for key in set(dic_normal.keys()) | set(dic_test.keys()):
            if key in dic_normal and key not in dic_test:
                total_dic[key] = dic_normal[key]
            elif key in dic_test and key not in dic_normal:
                total_dic[key] = dic_test[key]
            else:
                for Key in (set(dic_normal[key].keys()) | set(dic_test[key].keys())):
                    if Key in dic_test[key] and Key not in dic_normal[key]:
                        total_dic[key] = dic_test[key]
                        break
                    elif Key in dic_test[key] and Key in dic_normal[key]:
                        if (dic_test[key][Key] - dic_normal[key][Key]) / dic_normal[key][Key] > 0.1:
                            total_dic[key] = [dic_normal[key], dic_test[key]]
                            break
        fp.write(json.dumps(total_dic, indent=2, ensure_ascii=False) + '\n')

    if total_dic:
        for key in total_dic:
            try:
		if os.path.exists('/usr/local/waf_test/tmp/'+baseline_version+'-'+data_version+'-'+mode+'/error_status/'+key):
                    os.system('cp -rf /usr/local/waf_test/tmp/'+baseline_version+'-'+data_version+'-'+mode+'/error_status/'+key+' '+testPath+'/domain/baseline/')
                if os.path.exists('/usr/local/waf_test/tmp/' + guid + '-' + mode + '/error_status/' + key):
		    os.system('cp -rf /usr/local/waf_test/tmp/' + guid + '-' + mode + '/error_status/' + key + ' ' + testPath + '/domain/test/')
            except Exception as msg:
                logging.error(msg)
