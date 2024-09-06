package;

import savenotdrip.INITools;

class ParseTest
{
    public static function main()
    {
        var parsedIni:Dynamic = INITools.parse('../../../../test.svndp');

        trace('\n' + parsedIni);

        var stringifiedIni:String = INITools.stringify(parsedIni);

        trace('\n' + stringifiedIni);
    }
}