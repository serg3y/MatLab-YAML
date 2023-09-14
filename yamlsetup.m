function yamlsetup(fold,save,ver)
%Download and add SnakeYAML-<ver>.jar to MatLab's javaclasspath.
% yamlsetup          -download jar to same folder as this m file
% yamlsetup(fold)      -download to custom folder
% yamlsetup(fold,save)   -if true adds jar to static javaclasspath.txt
% yamlsetup(fold,save,ver)  -set SnakeYAML version (default: '2.0')
%
%See also: yamlread, yamlwrite

%defaults
if nargin<1 || isempty(fold), fold = fileparts(mfilename('fullpath')); end
if nargin<2 || isempty(save), save = false; end
if nargin<3 || isempty(ver),  ver  = '2.0'; end

jar = ['snakeyaml-' ver '.jar']; %name of jar file
pth = fullfile(fold,jar);
url = ['https://repo1.maven.org/maven2/org/yaml/snakeyaml/' ver '/snakeyaml-' ver '.jar'];

%download snakeyaml
if ~isfile(pth)
    websave(pth,url);
end

%add jar file temporarily to dynamic javaclasspath
if ~any(contains(javaclasspath('-all'),jar))
    javaaddpath(pth)
end

%add jar file permanently to static javaclasspath
if save
    javaPathsFile = fullfile(userpath,'javaclasspath.txt');
    if isfile(javaPathsFile)
        javapath = regexp(strip(fileread(javaPathsFile)),'[\r\n]','split')'; %read existing file
    else
        javapath = {};
    end
    javapath = regexprep(javapath,'.*snakeyaml.*',''); %remove old paths
    javapath(cellfun(@isempty,javapath)) = [];
    javapath = [javapath; pth]; %append new path to the end
    fid = fopen(javaPathsFile,'w');
    fprintf(fid,'%s\n',javapath{:}); %write new path
    fclose(fid);
end