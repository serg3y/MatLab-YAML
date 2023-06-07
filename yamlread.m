function [data,txt] = yamlread(txt)
%Convert YAML text to data (uses SnakeYAML).
% data = yamlread(file)
% data = yamlread(txt)
% [data,str] = yamlread(file)
%
%See also: yamlsetup, yamlwrite

%setup
if ~any(contains(javaclasspath('-all'),'snakeyaml'))
    yamlsetup
end

%read yaml text from file (optional)
if isfile(txt)
    txt = fileread(txt);
end

%parse yaml text
data = yamldecode(txt);

function data = yamldecode(txt)
J = org.yaml.snakeyaml.Yaml().load(txt); %intermediate java class
data = java2matlab(J); %convert to MatLab

function data = java2matlab(J)
%Convert Java class to MatLab struct
switch class(J)
    case 'java.util.ArrayList'
        data = cell(J.toArray)'; %convert list to cell row vector
        if isempty(data)
            data = {}; %size 0x0 cell rather then 1x0
        else
            for k = 1:numel(data)
                data{k} = java2matlab(data{k}); %also convert contents
            end
        end
    case 'java.util.LinkedHashMap'
        val = J.values.toArray; %values
        if isempty(val)
            data = struct();
        else
            par = J.keySet.toArray.string; %slow but handles edge cases such as 'a: 1\n2: 2'
            % par = cell(1,J.size); t = J.keySet.iterator; for k = 1:J.size, par{k} = t.next.string; end %fast but fails on edge cases 
            %the alternative is slower: par = cellstr(char(J.keySet.toArray)); %medium but fails on some edge cases
            par = matlab.lang.makeValidName(par); %ensure field names are valid, replace bad charecters with _, prefix x to leading numbers
            par = matlab.lang.makeUniqueStrings(par); %ensure parameters are unique, append _1 _2 if needed
            for k = 1:numel(par)
                data.(par{k}) = java2matlab(val(k)); %assign and also convert contents
            end
        end
    case 'java.util.Date'
        data = datetime(J.getTime/1000,'ConvertFrom','posixtime','TimeZone','UTC');
        data.Format = 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''; %display format only, note java rounds milliseconds
    case {'char' 'double' 'logical'}
        data = J; %do nothing
    otherwise
        data = J;
        fprintf(2,'Unsupported data type: %s\n',class(J))
end