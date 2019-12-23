<?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
        xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
        xmlns:cdm="http://www.oclc.org/contentdm"
        exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
        version="2.0">
        
        <!-- Template for updating titles by concatenating the date  -->
        
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
        <!-- on book and newspaper cModel objects that have a value for the date, concatenate it to the value of the title -->
        <xsl:template match="mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[matches(.,'(bookCModel|newspaperIssueCModel|compound)')]][mods:originInfo/mods:dateIssued[normalize-space()]]/mods:titleInfo[not(@*)]/mods:title" exclude-result-prefixes="#all">
            <xsl:variable name="date" select="ancestor::mods:mods/mods:originInfo/mods:dateIssued[1]"/>
            <xsl:message select="normalize-space(concat(.,' ',$date))"/>
            <title xmlns="http://www.loc.gov/mods/v3">
                <xsl:value-of select="normalize-space(concat(.,' ',$date))"/>
            </title>
        </xsl:template>

    </xsl:stylesheet> 
