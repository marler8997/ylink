
import std.path;

import workqueue;
import objectfile;

class Directive
{
    this()
    {
    }
    void apply(ObjectFiles objectFiles)
    {
        assert(0);
    }
}

class LibDirective : Directive
{
    immutable(ubyte)[] name;
    this(immutable(ubyte)[] name)
    {
        this.name = name;
    }
    override void apply(ObjectFiles objectFiles)
    {
        objectFiles.putName(defaultExtension(cast(string)name, "lib"));
    }
}

class NoLibDirective : Directive
{
    immutable(ubyte)[] name;
    this(immutable(ubyte)[] name)
    {
        this.name = name;
    }
    override void apply(ObjectFiles objectFiles)
    {
    }
}
