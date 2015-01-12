#!/usr/bin/env python
# __author__ = 'dgilliland'

import argparse, re, uuid, sys, os, calendar, re

from pdfminer.pdfparser import PDFParser
from pdfminer.pdfpage import PDFPage
from pdfminer.pdfinterp import PDFResourceManager
from pdfminer.pdfinterp import PDFPageInterpreter
from pdfminer.converter import TextConverter
from pdfminer.layout import LAParams

sys.path.append("./lib")

from utils.file import spit, slurpA, rm

def header_row():
    row = '\t'.join(['','URL','Symposium','Title','Abstract','year','fall','n','awords','twords', '\n'])
    return row

def pdf_miner(file_dir, file_name):
    tmp_file_name = '.tmp.txt'
    rsrcmgr = PDFResourceManager(caching=True)
    output = open(tmp_file_name, 'w')
    device = TextConverter(rsrcmgr, output, laparams=LAParams())
    fp = open('{}/{}'.format(file_dir, str(file_name)), 'rb')
    interpreter = PDFPageInterpreter(rsrcmgr, device)
    for page in PDFPage.get_pages(fp):
        interpreter.process_page(page)
    fp.close()
    device.close()
    output.close()
    return tmp_file_name

def isMonth(str_month):
    if str_month in calendar.month_name:
        return True
    else:
        return False

def parse_entry(line_buffer):

    sentences = line_buffer.split('.', 2)
    if len(sentences) >= 3:
        field1 = sentences[0]
        field2 = sentences[1] + sentences[2]

        return field1, field2
    else:
        return 'unparsable', 'unparsable'

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Transform Cables to Newman Ingest Format')
    parser.add_argument("pdf_dir", help="directory containing pdf abstract files")
    parser.add_argument("output_file", help="output file name (MRS.csv?)")
    parser.add_argument("url", help="url pdf files came from (http://www.mrs.org/...")
    parser.add_argument("is_fall", help="TRUE or FALSE")
    parser.add_argument("year_override", help="If your data fails on year, it is not parsable.  Pass in here")

    args= parser.parse_args()

    pdf_files = os.listdir(args.pdf_dir)

    time_loc_pattern = re.compile(r'\d{1,2}[:]\d\d\s*[AaPpMm]')

    spit(args.output_file, header_row(), True)

    url = args.url
    fall = args.is_fall
    year = args.year_override
    n = '0'
    awords = '0'
    twords = '0'

    id = 0

    #for each file in the directory
    for file_index, file in enumerate(pdf_files):

        if file.endswith('.PDF') or file.endswith('.pdf'):
            print 'Executing PDF parser on {}'.format(file)
            tmp_file = pdf_miner(args.pdf_dir, file)

            pdf_lines = slurpA(tmp_file)
            rm(tmp_file)

            line_buffer = ''
            symp_to_year_flag = False
            found_start_flag = False
            start_line = 0
            counter = 0 ###
            print 'Writing {} to output file'.format(file)
            for line_index, line in enumerate(pdf_lines):

                if line_index < 5 and line[:9] == 'SYMPOSIUM':
                    symposium = line.strip()
                    symp_to_year_flag = True
                elif symp_to_year_flag and line_index < 12:
                    segments = line.split()
                    if len(segments) > 0:
                        if isMonth(segments[0]):
                            year = segments[len(segments) - 1].strip()
                            symposium = '{} | {} | {}'.format(year, symposium, line_buffer)
                            symp_to_year_flag = False
                            line_buffer = ''
                        else:
                            line_buffer = line_buffer + ' ' + line.strip()
                elif found_start_flag:
                    if len(line) > 0:
                        if line[:7] == 'SESSION' or time_loc_pattern.search(line.strip()) is not None:
                            #line_buffer = re.sub(r'[^\x00-\x7F]',' ', line_buffer)
                            title, abstract = parse_entry(line_buffer)
                            if title != 'unparsable' and abstract != 'unparsable':

                                out_row = '\t'.join([year+str(id), url, symposium, title, abstract, year, fall, n, awords, twords, '\n'])
                                spit(args.output_file, out_row)
                                id = id + 1
                            found_start_flag = False
                            line_buffer = ''

                        else:
                            #add clean up cases here else add the line to the buffer
                            line_buffer = line_buffer + ' ' + line.strip()
                    elif line_index == start_line + 1:
                        # case where you find a valid time pattern, but the following line is blank
                        found_start_flag = False

                if not found_start_flag and time_loc_pattern.search(line.strip()) is not None:
                    found_start_flag = True
                    start_line = line_index


    sys.exit(1)