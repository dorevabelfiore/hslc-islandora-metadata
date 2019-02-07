<?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema" 
        xmlns:mods="http://www.loc.gov/mods/v3"
        xmlns:dcterms="http://purl.org/dc/terms/"
        exclude-result-prefixes="xs" 
        version="2.0">

        <!-- Template to crosswalk MODS to Qualified Dublin Core per HSLC specs  -->
        <!-- Designed only for use in Islandora, where root element will _always_ be /mods. -->

        <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

        <xsl:strip-space elements="*"/>

        <xsl:template match="/">
            <qualifieddc xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xsi:noNamespaceSchemaLocation="http://dublincore.org/schemas/xmls/qdc/2008/02/11/qualifieddc.xsd">
                <xsl:for-each select="mods:mods">
                    <xsl:apply-templates/>
                </xsl:for-each>
            </qualifieddc>
        </xsl:template>

        <xsl:template match="mods:titleInfo[not(@type)]">
            <dcterms:title><xsl:value-of select="normalize-space(mods:title)"/></dcterms:title>
        </xsl:template>

        <xsl:template match="mods:titleInfo[matches(@type,'alternative|masthead')]">
            <dcterms:alternative><xsl:value-of select="normalize-space(mods:title)"/></dcterms:alternative>
        </xsl:template>

        <xsl:template match="mods:relatedItem[@otherType = 'Replaces']">
            <dcterms:replaces><xsl:value-of select="normalize-space(mods:titleInfo/mods:title)"/></dcterms:replaces>
        </xsl:template>

        <xsl:template match="mods:relatedItem[@otherType = 'Is Replaced By']">
            <dcterms:isReplacedBy><xsl:value-of select="normalize-space(mods:titleInfo/mods:title)"/></dcterms:isReplacedBy>
        </xsl:template>

        <xsl:template match="mods:subject">
            <xsl:for-each select="mods:topic">
                <dcterms:subject><xsl:value-of select="."/></dcterms:subject>
            </xsl:for-each>
            <xsl:for-each select="mods:geographic">
                <dcterms:spatial><xsl:value-of select="."/></dcterms:spatial>
            </xsl:for-each>
            <xsl:for-each select="mods:temporal">
                <dcterms:temporal><xsl:value-of select="."/></dcterms:temporal>
            </xsl:for-each>
        </xsl:template>     

        <xsl:template match="mods:abstract">
            <dcterms:description><xsl:apply-templates/></dcterms:description>
        </xsl:template>

        <xsl:template match="mods:name">
            <xsl:choose>
                <xsl:when test="mods:role/mods:roleTerm[. = 'Creator']">
                    <dcterms:creator>
                        <xsl:call-template name="nameParts"/>
                    </dcterms:creator>
                </xsl:when>
                <xsl:when test="mods:role/mods:roleTerm[matches(.,('Contributor|Interviewe'))]">
                    <dcterms:contributor>
                        <xsl:call-template name="nameParts"/>
                    </dcterms:contributor>
                </xsl:when>
            </xsl:choose>
        </xsl:template>

        <xsl:template name="nameParts">
            <xsl:for-each select="mods:namePart">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:template>

        <xsl:template match="mods:originInfo">
            <xsl:if test="mods:publisher[normalize-space()]">
                <dcterms:publisher><xsl:value-of select="normalize-space(mods:publisher)"/></dcterms:publisher>
            </xsl:if>
            <xsl:if test="mods:dateIssued[normalize-space()]">
                <dcterms:date><xsl:value-of select="normalize-space(mods:dateIssued)"/></dcterms:date>
            </xsl:if>
        </xsl:template>

        <xsl:template match="mods:typeOfResource">
            <dcterms:type><xsl:apply-templates/></dcterms:type>
        </xsl:template>

        <xsl:template match="mods:physicalDescription">
            <xsl:if test="mods:form[normalize-space()]">
                <dcterms:medium><xsl:value-of select="normalize-space(mods:form)"/></dcterms:medium>
            </xsl:if>
            <xsl:if test="mods:internetMediaType[normalize-space()]">
                <dcterms:format><xsl:value-of select="normalize-space(mods:internetMediaType)"/></dcterms:format>
            </xsl:if>
        </xsl:template>

        <xsl:template match="mods:identifier">
            <dcterms:identifier><xsl:apply-templates/></dcterms:identifier>
        </xsl:template>

        <xsl:template match="mods:relatedItem[@type = 'host']">
            <dcterms:source><xsl:value-of select="normalize-space(mods:titleInfo/mods:title)"/></dcterms:source>
        </xsl:template>

        <xsl:template match="mods:language[mods:languageTerm[normalize-space()]]">
            <dcterms:language><xsl:value-of select="mods:languageTerm"/></dcterms:language>
        </xsl:template>

        <xsl:template match="mods:relatedItem[not(@type) and not(@otherType)]">
            <dcterms:relation><xsl:value-of select="normalize-space(mods:titleInfo/mods:title)"/></dcterms:relation>
        </xsl:template>

        <xsl:template match="mods:note[@type = 'provenance']">
            <dcterms:provenance><xsl:apply-templates/></dcterms:provenance>
        </xsl:template>

        <xsl:template match="mods:targetAudience">
            <dcterms:audience><xsl:apply-templates/></dcterms:audience>
        </xsl:template>

        <xsl:template match="mods:accessCondition[@type = 'use and reproduction']">
            <dcterms:rights><xsl:apply-templates/></dcterms:rights>
        </xsl:template>

        <xsl:template match="mods:note[not(@type)]">
            <dcterms:description><xsl:apply-templates/></dcterms:description>
        </xsl:template>

       <xsl:template match="*"/>

    </xsl:stylesheet> 
