import re
import PyPDF2
import sys
import os
import yaml
from dataclasses import dataclass

@dataclass
class Section:
    key: str = ""
    title: str = ""
    filename : str = ""
    firstpage : int  = 0
    lastpage  : int = 999
    number : str = ""
    href   : str = ""
    level  : int = 0

def chapters(reader,sections,bookmark_list=None, lastitems = ["","","","","","",""], lastpage = 1, curlevel = 0, maxlevel = 1):
    if maxlevel<curlevel: return sections
    if not bookmark_list:
        bookmark_list = reader.getOutlines()
    for item in bookmark_list:
        if isinstance(item,list):
            chapters(reader,sections,item,lastitems,lastpage,curlevel+1,maxlevel)
        if isinstance(item,PyPDF2.generic.Destination):
            newpage = reader.getDestinationPageNumber(item)
            if lastitems[curlevel] in sections:
                sections[lastitems[curlevel]].lastpage = newpage-1
                # print(f"{lastitems[curlevel]}'s last page page is {newpage-1}")
            key = digest(item.title)
            lastitems[curlevel] = key
            if key in sections:
                sections[key].firstpage = newpage
                #print(f"{key}'s first page is {newpage}")
            else:
                print(f"Key {key} not found")
    return sections



def loadyaml(file, default={}):
    """Utility function to load from yaml file"""
    try:
        with open(file, "r", encoding="utf-8") as f:
            t = yaml.load(f)
    except FileNotFoundError:
        t = default
    return t


def digest(s):
    if len(s)>30:
        s = s[:30]
    return re.sub(r'\W+','', s.lower())


def initsections(tocfile, maxlevel = 0):
    sections = {}
    booktoc = loadyaml(tocfile)
    for num,sec in booktoc.items():
        if num.count('.')>maxlevel: continue
        filename = os.path.splitext(sec["filename"])[0]
        s = Section(digest(sec["title"]), title= sec["title"], filename = filename, number=num, href = sec["href"])
        sections[s.key] = s
    return sections

def splitchapters(reader,sections):
    for key,sec in sections.items():
        print(f"Creating {sec.filename}.pdf ({sec.title}, pages {sec.firstpage}-{sec.lastpage}..")
        writer = PyPDF2.PdfFileWriter()
        for i in range(sec.firstpage,min(sec.lastpage,reader.getNumPages()-1)+1):
            writer.addPage(reader.getPage(i))
        with open(sec.filename+'.pdf', 'wb') as outfile:
            writer.write(outfile)
        print("done")



def main():
    args = sys.argv[1:]
    pdffile = args[0] if len(args)>0 else "lnotes_book.pdf"
    tocfile = args[1] if len(args)>1 else "toc.yaml"
    sections = initsections(tocfile)
    sections["contentsdetailed"] = Section(filename = "contents", title= "Contents (detailed)")
    reader = PyPDF2.PdfFileReader(pdffile)
    chapters(reader,sections)
    splitchapters(reader,sections)


if __name__ == '__main__':
    main()


