function [J,str] = yamlwrite(S,file)
%Convert struct to Java class and write to YAML file using Snakeyaml.
% yamlwrite(S,file)
% [J,str] = yamlwrite(S,file)
%
%See also: yamlsetup, yamlread

%setup
if ~any(contains(javaclasspath('-all'),'snakeyaml'))
    yamlsetup
end

%convert to java
J = matlab2java(S);

%generate yaml string using snakeyaml
str = org.yaml.snakeyaml.Yaml().dump(J).char;

%write to file
if nargin>1 && ~isempty(file)
    fid = fopen(file,'w');
    fprintf(fid,'%s',str);
    fclose(fid);
end

function J = matlab2java(S)
%Convert MatLab struct to Java class
if ischar(S)
    J = java.lang.String(S);
elseif isnumeric(S) && isempty(S)
    J = false(0); %converts to null
elseif isnumeric(S)
    J = java.lang.Double(S);
elseif islogical(S)
    J = java.lang.Boolean(S);
elseif iscell(S)
    J = java.util.ArrayList;
    for k = 1:size(S,2)
        J.add(matlab2java(S{k}));
    end
elseif isstruct(S)
    J = java.util.LinkedHashMap;
    for f = string(fields(S))'
        J.put(f,matlab2java(S.(f)));
    end
elseif isdatetime(S)
    %time with milisec: 2011-03-29T16:09:20.667Z
    J = java.util.Calendar.getInstance();
    J.setTimeInMillis(S.Second*1000);
    [Y,M,D,h,m,s] = datevec(S);
    J.set(Y,M-1,D,h,m,s);
    J.setTimeZone(java.util.TimeZone.getTimeZone("UTC"));
else
    J = S;
    fprintf(2,'Unsupported data type: %s\n',class(S));
end