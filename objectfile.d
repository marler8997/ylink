
import std.array;
import std.path;
import std.string;
import std.stdio;

import linker;
import datafile;
import modules;
import omflibraryfile;
import omfobjectfile;
import cofflibraryfile;
import coffobjectfile;
import sectiontable;
import symboltable;
import workqueue;

struct ObjectFilename
{
    public string filename;
    public string keyName;
    public this(string filename, string keyName)
	{
        this.filename = filename;
        this.keyName = keyName;
    }
}
class ObjectFiles
{
    ObjectFilename[string] keyNameObjectMap;
    auto queue = new WorkQueue!string();

    auto objectFiles = appender!(ObjectFile[])();

    this(string[] objectFilenames)
	{
        foreach(string filename; objectFilenames) {
            putName(filename);
        }
    }

    public bool emptyNames() { return queue.empty(); }
    public string popName() { return queue.pop(); }
    public void putName(string name)
    {
        string keyName = baseName(name).toLower();
        ObjectFilename* existing = keyName in keyNameObjectMap;

        if(existing !is null)
        {
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // Uncomment this once the verbosity pull request is merged
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            //if(verbosity > 0)
            //{
            //    writefln("verbose: ObjectFile '%s' already exists (keyName='%s')", name, keyName);
            //}

            // TODO: should I check if the paths are different?
        }
        else
        {
            keyNameObjectMap[keyName] = ObjectFilename(name, keyName);
            queue.append(name);
        }
    }
    public void putObjectFile(ObjectFile objectFile)
    {
        objectFiles.put(objectFile);
    }
}

abstract class ObjectFile : Module
{
    this(string name)
    {
        super(name);
    }

    static ObjectFile detectFormat(DataFile f)
    {
        switch(f.peekByte())
        {
        case 0x80:
            return new OmfObjectFile(f);
        case 0xF0:
            return new OmfLibraryFile(f);
        case 0x4C:
            return new CoffObjectFile(f);
        case 0x00:
            return new CoffImportFile(f);
        case 0x21:
            return new CoffLibraryFile(f);
        default:
            return null;
        }
    }
    abstract void dump();
    abstract void loadSymbols(SymbolTable symtab, SectionTable segtab, ObjectFiles objectFiles);
    abstract void loadData(uint tlsBase);
}
