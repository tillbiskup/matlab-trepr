function docNode = struct2xml(str)
% XML2STRUCT Convert XML into struct
%
% Usage:
%   docNode = xml2struct(struct);
%
%   struct  - struct
%             content of the XML file
%   docNode - string
%             XML tree, org.apache.xerces.dom.DocumentImpl
%

% (c) 2010, Martin Hussels
% (c) 2010-2012, Till Biskup
% 2012-06-08

docNode = com.mathworks.xml.XMLUtils.createDocument(inputname(1));
docRootNode = docNode.getDocumentElement;
function traverse(thiselement,childnode)
    if isstruct(thiselement)
        childnode.setAttributeNode(docNode.createAttribute('class'));
        childnode.setAttribute('class',class(thiselement));
        childnode.setAttributeNode(docNode.createAttribute('size'));
        childnode.setAttribute('size',mat2str(size(thiselement)));
        for i=1:length(thiselement(:))
            names=fieldnames(thiselement(i));
            for n=1:length(names)
                name=names{n};
                nextnode=docNode.createElement(name);
                nextnode.setAttributeNode(docNode.createAttribute('id'));
                nextnode.setAttribute('id',num2str(i));
                traverse(thiselement(i).(name),nextnode);
                childnode.appendChild(nextnode);
            end
        end
    elseif iscell(thiselement)
        childnode.setAttributeNode(docNode.createAttribute('class'));
        childnode.setAttribute('class',class(thiselement));
        childnode.setAttributeNode(docNode.createAttribute('size'));
        childnode.setAttribute('size',mat2str(size(thiselement)));
        for i=1:length(thiselement(:))
            nextnode=docNode.createElement('cell');
            nextnode.setAttributeNode(docNode.createAttribute('id'));
            nextnode.setAttribute('id',num2str(i));
            traverse(thiselement{i},nextnode);
            childnode.appendChild(nextnode);
        end
    else
        if strcmp(class(thiselement),'function_handle') 
            thiselement = func2str(thiselement);
        end
        childnode.setAttributeNode(docNode.createAttribute('class'));
        childnode.setAttribute('class',class(thiselement));
        childnode.setAttributeNode(docNode.createAttribute('size'));
        childnode.setAttribute('size',mat2str(size(thiselement)));
        childnode.setTextContent(num2str(reshape(thiselement,1,[])));
    end
end
traverse(str,docRootNode);
end