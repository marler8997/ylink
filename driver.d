
import std.exception;
import std.string;
import std.stdio;

import relocation;
import sectiontable;
import segment;
import symboltable;
import workqueue;
import objectfile;
import linker;
import paths;
import datafile;

void loadObjects(ObjectFiles objectFiles, Paths paths, SymbolTable symtab, SectionTable sectab)
{
    while (!objectFiles.emptyNames())
    {
        string filename = objectFiles.popName();

        if (!paths.search(filename))
            writeln("Warning - File not found: " ~ filename);
        else
        {
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // Uncomment this once the verbosity pull request is merged
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            //if (verbosity > 0)
            //    debug writefln("verbose: Loading '%s'", filename);

            auto object = ObjectFile.detectFormat(new DataFile(filename));
            enforce(object, "Unknown object file format: " ~ filename);
            object.loadSymbols(symtab, sectab, objectFiles);
        }
    }
}

void finalizeLoad(SymbolTable symtab, SectionTable sectab)
{
    symtab.defineImports(sectab);
    symtab.allocateComdef(sectab);
    symtab.defineSpecial(sectab, imageBase);
    symtab.checkUnresolved();
}

Segment[SegmentType] generateSegments(ObjectFiles objectFiles, SymbolTable symtab, SectionTable sectab)
{
    auto segments = sectab.allocateSegments(imageBase, segAlign, fileAlign);
    symtab.buildImports(segments[SegmentType.Import].data, imageBase);

    foreach (ObjectFile object; objectFiles.objectFiles.data)
    {
        object.loadData((SegmentType.TLS in segments) ? segments[SegmentType.TLS].base : -1);
    }
    return segments;
}
