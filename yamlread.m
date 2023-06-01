function [S,J,str] = yamlread(file)
%Read YAML file using SnakeYAML and convert Java class to struct.
% S = yamlread(str)
% S = yamlread(file)
% [S,J,str] = yamlread(file)
%
%See also: yamlsetup, yamlwrite

%setup
if ~any(contains(javaclasspath('-all'),'snakeyaml'))
    yamlsetup
end

%read text file as string
if isfile(file)
    str = fileread(file);
else
    str = file;
end

%parse using snakeyaml
J = org.yaml.snakeyaml.Yaml().load(str);

%convert to struct
S = java2matlab(J);

function S = java2matlab(J)
%Convert Java class to MatLab struct
if isa(J,'java.util.List') 
    S = J.toArray.cell'; %convert list to cell row vector
    for k = 1:numel(S)
        S{k} = java2matlab(S{k}); %also convert contents
    end
elseif isa(J,'java.util.Map')
    par = J.keySet.toArray;
    val = J.values.toArray;
    for k = 1:numel(par)
        S.(par(k)) = java2matlab(val(k)); %assign and also convert contents
    end
elseif isa(J,'java.util.Date')
    S = datetime(J.getTime/1000,'ConvertFrom','posixtime');
    S.Format = 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''; %java rounds milliseconds
elseif ismember(class(J),{'char' 'double' 'logical'})
    S = J; %do nothing for: char, double, logical, unknown
else
    fprintf(2,'Unsupported data type: %s\n',class(J))
end