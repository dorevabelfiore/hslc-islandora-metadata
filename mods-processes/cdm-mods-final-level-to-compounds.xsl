<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <!-- Template to change final level in hierarchy to a compound. -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:strip-space elements="*"/>
    
    <xsl:param name="islandora-namespace" required="yes"/>
    <xsl:variable name="islandora-namespace-prefix" select="concat($islandora-namespace,':')"/>
 
    
    <!-- build hierarchy for reference -->
    <xsl:variable name="tree" exclude-result-prefixes="#all">
        <tree>
            <xsl:for-each
                select="/mods:modsCollection/mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:collectionCModel']][mods:relatedItem[@otherType = 'islandoraCollection'][not(contains(mods:identifier, '_'))]]">
                <xsl:variable name="node-id" select="concat($islandora-namespace-prefix,mods:identifier[@type = 'islandora'])"/>
                <xsl:variable name="cmodel"
                    select="mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier"/>
                <xsl:call-template name="recurse-nodes">
                    <xsl:with-param name="node-id" select="$node-id"/>
                    <xsl:with-param name="cmodel" select="$cmodel"/>
                </xsl:call-template>
            </xsl:for-each>
        </tree>
    </xsl:variable>
    
    <xsl:template name="recurse-nodes" exclude-result-prefixes="#all">
        <xsl:param name="node-id"/>
        <xsl:param name="cmodel"/>
        <node id="{substring-after($node-id,$islandora-namespace-prefix)}" cmodel="{$cmodel}">
            <xsl:for-each
                select="/mods:modsCollection/mods:mods[mods:relatedItem[@otherType = 'islandoraCollection']/mods:identifier[. = $node-id]]">
                <xsl:variable name="node-id" select="concat($islandora-namespace-prefix,mods:identifier[@type = 'islandora'])"/>
                <xsl:variable name="cmodel"
                    select="mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier"/>
                    <xsl:call-template name="recurse-nodes">
                        <xsl:with-param name="node-id" select="$node-id"/>
                        <xsl:with-param name="cmodel" select="$cmodel"/>
                    </xsl:call-template>
            </xsl:for-each>
        </node>
    </xsl:template>
    
   <!-- make collections with one level of image children a compound -->
    <xsl:template match="mods:mods/mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:collectionCModel']" exclude-result-prefixes="#all">
        <xsl:variable name="identifier" select="ancestor::mods:mods/mods:identifier[@type = 'islandora']"/>
        <xsl:choose>
            <!-- when this collection only has image children make it a compound -->
            <xsl:when test="$tree//node[@id = $identifier][not(descendant::node[@cmodel = 'islandora:collectionCModel']) and not(node[not(matches(@cmodel,'image'))])]">
                <identifier xmlns="http://www.loc.gov/mods/v3">islandora:compoundCModel</identifier>
            </xsl:when>
            <!--  or let it be -->
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- make image objects whose parent collection has only one level and nothing but images children a compound child -->
    <xsl:template match="mods:mods[matches(mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier,'image')]/mods:relatedItem[@otherType = 'islandoraCollection']" exclude-result-prefixes="#all">
        <xsl:variable name="identifier" select="parent::mods:mods/mods:identifier[@type = 'islandora']"/>
        <xsl:variable name="book-identifier" select="mods:identifier"/>
        <xsl:choose>
            <!-- when: parent is a collection, does not have any subcollections, and none of its children are not images, 
                 this object gets isChildOf relationship to it -->
            <xsl:when test="$tree//node[@id = $identifier][not(parent::node/node[@cmodel = 'islandora:collectionCModel'])][not(parent::node/node[not(matches(@cmodel,'image'))])]">
                <xsl:variable name="identifier" select="ancestor::mods:mods/mods:identifier[@type = 'islandora']"/>
                <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="isChildOf" otherTypeAuth="dgi">
                    <identifier><xsl:value-of select="substring-after($book-identifier,':')"/></identifier>
                </relatedItem>
            </xsl:when>
            <!-- or let it be -->
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    
    <!-- identity transform to copy through all nodes (except those with specific templates modifying them -->    
    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
        <xsl:result-document href="tree.xml" method="xml" indent="yes">
            <xsl:copy-of select="$tree"/>
        </xsl:result-document>
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
    
   
</xsl:stylesheet>
