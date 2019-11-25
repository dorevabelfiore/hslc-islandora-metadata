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
        
        <!-- updates -->
        
        <!--  
             whether ';' present or not, tokenizing on it will work correctly
             
             Assumption: (since coming from ContentDM: only one namePart in /mods/name.
        -->
        <xsl:template match="mods:mods/mods:name[mods:namePart[normalize-space()]]" exclude-result-prefixes="#all">
            <xsl:variable name="name-attributes" select="@*"/>
            <!-- store sibling elements, e.g. role -->
            <xsl:variable name="namepart-siblings" select="*[not(self::mods:namePart)]"/>
            <xsl:for-each select="mods:namePart">
                <xsl:for-each select="tokenize(.,';')">
                    <name xmlns="http://www.loc.gov/mods/v3">
                        <xsl:copy-of select="$name-attributes"/>
                        <namePart><xsl:value-of select="normalize-space(.)"/></namePart>
                        <!-- each name should include the namepart siblings -->
                        <xsl:apply-templates select="$namepart-siblings"/>
                    </name>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:template>
        
        <!-- split multivalue /subject/(geographic|topic|temporal) on ';' -->
        <xsl:template match="mods:subject[count(*) = 1][(mods:geographic|mods:temporal|mods:topic)[contains(.,';')]][not(count(mods:topic[normalize-space()]) > 1)]" exclude-result-prefixes="#all">
            <xsl:variable name="subject-attributes" select="@*"/>
            <xsl:variable name="subject-child-name" select="local-name(child::*)"/>
            <xsl:for-each select="*">
                <xsl:for-each select="tokenize(.,';')">
                    <subject xmlns="http://www.loc.gov/mods/v3">
                        <xsl:copy-of select="$subject-attributes"/>
                        <xsl:element name="{$subject-child-name}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
                    </subject>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:template>
        
        <!-- additions for Lycoming Womens History -->
        <!-- /mods/subject[count(topic) > 1] -->
        <xsl:template match="mods:subject[count(mods:topic[normalize-space()]) > 1][not(mods:*[local-name() != 'topic'])]" exclude-result-prefixes="#all">
            <xsl:variable name="subject-attributes" select="@*"/>
            <!-- each topic becomes its own /mods/subject/topic -->
            <xsl:for-each select="mods:topic">
                <!-- which needs to be split further if there are delimited values -->
                <xsl:for-each select="tokenize(.,';')[normalize-space()]">
                    <subject xmlns="http://www.loc.gov/mods/v3">
                        <xsl:copy-of select="$subject-attributes"/>
                        <topic><xsl:value-of select="normalize-space(.)"/></topic>
                    </subject>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:template>
        
        <!-- /mods/relatedItem[not(@type)]/titleInfo[count(mods:title) > 1] -->
        <xsl:template match="mods:relatedItem[not(@type)][mods:titleInfo[count(mods:title) > 1]]" exclude-result-prefixes="#all">
            <xsl:for-each select="mods:titleInfo/mods:title">
                <relatedItem xmlns="http://www.loc.gov/mods/v3">
                    <titleInfo><xsl:copy-of select="."/></titleInfo>
                </relatedItem>
            </xsl:for-each>
        </xsl:template>
        
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
