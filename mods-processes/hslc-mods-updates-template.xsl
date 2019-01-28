<?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
        xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
        xmlns:cdm="http://www.oclc.org/contentdm"
        exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
        version="2.0">
        
        <!-- Template for cleanup of ContentDM-to-MODS crosswalk output prior to ingest to Islandora.  -->
        
        <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
        
        <xsl:strip-space elements="*"/>
        
        
        <!-- identity transform to copy through all nodes (except those with specific templates modifying them) -->    
        <xsl:template match="/" exclude-result-prefixes="#all">
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:template>
        
        <xsl:template match="* | @*" exclude-result-prefixes="#all">
            <xsl:copy>
                <xsl:apply-templates select="@* | *| text() | comment() | processing-instruction()"/>
            </xsl:copy>
        </xsl:template>
        
        <!-- keep comments and PIs						-->
        <xsl:template match="comment() | processing-instruction()">
            <xsl:copy-of select="."/>
        </xsl:template>
        
        <!-- updates TK -->
        
        <!-- remove selected empty elements -->
        <xsl:template match="mods:name[not(mods:namePart[normalize-space()])]
            | mods:extent[not(normalize-space())]
            | mods:physicalDescription[not(*[normalize-space()])]
            | mods:typeOfResource[not(normalize-space())]
            | mods:language[not(mods:languageTerm[normalize-space()])]
            | mods:relatedItem/mods:extension/*:FULLTEXT[not(normalize-space())]
            | mods:accessCondition[not(normalize-space())]
            | mods:note[not(normalize-space())]
            | mods:relatedItem[@otherType = 'FULLTEXTDatastream'][normalize-space(mods:extension) = '']
            | mods:titleInfo[@type = 'alternative'][not(mods:title[normalize-space()])]
            | mods:titleInfo[@otherType = 'masthead'][not(mods:title[normalize-space()])]
            | mods:relatedItem[not(matches(@otherType,'(islandoraCModel|islandoraCollection|isChildOf|OBJ|CDMDatastream|FULLTEXTDatastream)'))][not(mods:titleInfo/mods:title[normalize-space()])]
            | mods:part[not(descendant::*[normalize-space()])]
            | mods:name[mods:role/mods:roleTerm[matches(.,'Interview')]][not(mods:namePart[normalize-space()])]
            | mods:note[not(normalize-space())]
            | mods:subject[not(*[normalize-space()])]
            | mods:relatedItem[@type = 'otherFormat'][not(mods:location/mods:url[normalize-space()])]
            "/>
    </xsl:stylesheet> 
