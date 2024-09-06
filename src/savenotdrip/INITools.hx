package savenotdrip;

using StringTools;

class INITools
{
    // PARSING

    /**
     * Parse ini file.
     */
    public static function parse(path:String):Dynamic
    {
        if (sys.FileSystem.exists(path))
			return parseString(sys.io.File.getContent(path));
        else
            trace('[ERROR] Tried to parse a non-existent file! $path');

        return null;
    }
    /**
     * Parse string with the ini structure.
     */
    public static function parseString(text:String):Dynamic
    {
        var toReturn:Dynamic = {};

        var textSplit:Array<String> = text.split('\n');
        var skipUntil:Int = -1;

        for(i=>parseText in textSplit)
        {
            if(skipUntil > i || (parseText.length < 1 || parseText == null))
                continue;

            // trace('at split');
            var equalSplit:Array<String> = parseText.split('=');
            // trace('passed split $equalSplit');

            if(equalSplit[1] == '{')
            {
                var textSplitTypedef:Array<String> = [];
                for(j in 0...textSplit.length-i)
                {
                    if(j == 0) // idk how to fix better
                        continue;

                    // trace(textSplit[j+i]);
                    if(textSplit[j+i].endsWith('}'))
                    {
                        skipUntil = j+i+1;
                        break;
                    }
                    else
                        textSplitTypedef.push(textSplit[j+i].ltrim());
                }

                Reflect.setField(toReturn, equalSplit[0], parseString(textSplitTypedef.join('\n')));

                // trace('finished!');

                continue;
            }

            // trace('at field thing');
            Reflect.setField(toReturn, equalSplit[0], parseField(equalSplit[1]));
            // trace('passed field thing');
        }

        return toReturn;
    }

    private static function parseField(field:String):Dynamic
    {
        var convertedField:Dynamic = null;

        // go go 100 line long if chain
        if(field.startsWith('"') && field.endsWith('"'))
            convertedField = field.substring(1, field.length-1);
        else if(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-'].contains(field.charAt(0)))
        {
            if(field.contains('.'))
                convertedField = Std.parseFloat(field);
            else
                convertedField = Std.parseInt(field);
        }
        else if(['true', 'false'].contains(field))
            convertedField = (field == 'true');
        else if(field.startsWith('[') && field.endsWith(']'))
        {
            convertedField = [];
            for(i in field.substring(1, field.length-1).split(','))
                convertedField.push(parseField(i));
        }

        // trace('almost finished parseField [$field] [$convertedField]');

        return convertedField;
    }

    public static function stringify(iniFile:Dynamic):String
    {
        var toReturn:String = '';

        for(field in Reflect.fields(iniFile))
        {
            var value:Dynamic = Reflect.field(iniFile, field);

            if (Reflect.isFunction(value))
				continue;

            toReturn += '$field=';

            if(value is String)
                toReturn += '"$value"';
            /*else if(value is Int || value is Float || value is Bool)
                toReturn += Std.string(value);*/
            else if(value is Array)
            {
                var value:Array<Dynamic> = value;

                toReturn += '[';
                for(valueInArray in value)
                {
                    if(valueInArray is String)
                        toReturn += '"$valueInArray"';
                    else if(valueInArray is Int || valueInArray is Float || valueInArray is Bool) // for now...
                        toReturn += Std.string(valueInArray);

                    toReturn += ',';
                }
                toReturn = toReturn.substring(0, toReturn.length-1);
                toReturn += ']';
            }
            else if(value is haxe.ds.StringMap)
            {
                var value:haxe.ds.StringMap<Dynamic> = value;
                var typeDef:Dynamic = {};

                for (key in value.keys())
                    Reflect.setField(typeDef, key, value.get(key));

                toReturn += '{\n' + tabStringify(typeDef) + '\n}';
            }
            else if(Type.typeof(value) == TObject)
                toReturn += '{\n' + tabStringify(value) + '\n}';
            else
                toReturn += Std.string(value); // last resort

            toReturn += '\n';
        }

        return toReturn.substring(0, toReturn.length-1);
    }

    private static function tabStringify(iniFile:Dynamic):String
    {
        var toReturn:String = '';

        for(line in stringify(iniFile).split('\n'))
            toReturn += '  ' + line + '\n';

        return toReturn.substring(0, toReturn.length-1);
    }
}