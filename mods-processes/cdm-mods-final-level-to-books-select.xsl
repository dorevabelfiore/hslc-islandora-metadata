<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs" 
    version="2.0">

    <!-- Template to change to books:
         - final level in hierarchy, i.e. the last collection without a subcollection
         - compounds with only large image children
    -->
    <!-- This is not handling any single page books at this point, i.e. changing them to standalone images. -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:strip-space elements="*"/>

    <xsl:param name="islandora-namespace" required="yes"/>
    <xsl:variable name="islandora-namespace-prefix" select="concat($islandora-namespace,':')"/>

    
    <!-- build hierarchy for reference, top level collections then recurse; top level compounds -->
    <xsl:variable name="tree" exclude-result-prefixes="#all">
        <tree>
            <xsl:for-each
                select="/mods:modsCollection/mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:collectionCModel']][mods:relatedItem[@otherType = 'islandoraCollection'][not(contains(., '_'))]]">
                <xsl:variable name="node-id" select="concat($islandora-namespace-prefix,mods:identifier[@type = 'islandora'])"/>
                <xsl:variable name="cmodel"
                    select="mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier"/>
                <!-- This xsl:if/@test will filter out nodes that should be candidates to become a book. 
                     The test can be changed as needed, this is just an example that would only allow collections objects
                     containing 'scrapbook' in the title to be processed into books.
                     See 2nd location below where this test is also applied.
                -->
                <xsl:if test="contains(lower-case(mods:titleInfo/mods:title), 'scrapbook')">
                    <xsl:call-template name="recurse-nodes">
                        <xsl:with-param name="node-id" select="$node-id"/>
                        <xsl:with-param name="cmodel" select="$cmodel"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="/mods:modsCollection/mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:compoundCModel']]">
                <xsl:variable name="node-id" select="mods:identifier[@type = 'islandora']"/>
                <xsl:variable name="cmodel"
                    select="mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier"/>
                <!-- in the standard module crosswalk, ONLY single level compounds are created, 
                     so no recursion is needed to list the children -->
                <!-- this is the second location the test needs to be applied for selectively creatings
                     as with preceding, this is just an example
                -->
                <xsl:if test="contains(lower-case(mods:titleInfo/mods:title), 'scrapbook')">
                    <node id="{$node-id}" cmodel="{$cmodel}">
                        <xsl:for-each
                            select="/mods:modsCollection/mods:mods[mods:relatedItem[@otherType = 'isChildOf']/mods:identifier[. = $node-id]]">
                            <xsl:variable name="node-id"
                                select="mods:identifier[@type = 'islandora']"/>
                            <xsl:variable name="cmodel"
                                select="mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier"/>
                            <node id="{$node-id}" cmodel="{$cmodel}"/>
                        </xsl:for-each>
                    </node>
                </xsl:if>
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

   <!-- make collections with one level of image children a book -->
    <xsl:template match="mods:mods/mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:collectionCModel']" exclude-result-prefixes="#all">
        <xsl:variable name="identifier" select="ancestor::mods:mods/mods:identifier[@type = 'islandora']"/>
        <xsl:choose>
            <!-- when this collection only has image children make it a book -->
            <xsl:when test="$tree//node[@id = $identifier][not(descendant::node[@cmodel = 'islandora:collectionCModel']) and not(node[not(matches(@cmodel,'image'))])]">
                <identifier xmlns="http://www.loc.gov/mods/v3">islandora:bookCModel</identifier>
            </xsl:when>
            <!--  or let it be -->
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- make compounds with one level of image children a book -->
    <xsl:template match="mods:mods/mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:compoundCModel']" exclude-result-prefixes="#all">
        <xsl:variable name="identifier" select="ancestor::mods:mods/mods:identifier[@type = 'islandora']"/>
        <xsl:choose>
            <!-- when this compound only has image children make it a book -->
            <xsl:when test="$tree//node[@id = $identifier][not(node[not(matches(@cmodel,'image'))])]">
                <identifier xmlns="http://www.loc.gov/mods/v3">islandora:bookCModel</identifier>
            </xsl:when>
            <!--  or let it be -->
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- This template addresses the collection relationship of image records that are not the child of a compound.
         If the record has no non-image siblings and is to become a book page, the relationship type is 
         changed from islandoraCollection to isPageOf, otherwise it is copied through. 
         In this case removal of the collection association and creating the isPageOf relationship can be 
         handled in one template. Two subsequent templates handle image records that are the child of a compound.
    -->
    <xsl:template match="mods:mods[not(mods:relatedItem[@otherType = 'isChildOf'])][matches(mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier,'image')]/mods:relatedItem[@otherType = 'islandoraCollection']" exclude-result-prefixes="#all">
        <xsl:variable name="identifier" select="parent::mods:mods/mods:identifier[@type = 'islandora']"/>
        <xsl:variable name="book-identifier" select="normalize-space(mods:identifier)"/>
        <xsl:choose>
            <xsl:when test="$tree//node[@id = $identifier][not(parent::node/node[@cmodel = 'islandora:collectionCModel'])][not(parent::node/node[not(matches(@cmodel,'image'))])]">
                <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="isPageOf" otherTypeAuth="dgi">
                    <identifier>
                        <xsl:call-template name="book-identifier">
                            <xsl:with-param name="book-identifier" select="$book-identifier"/>
                        </xsl:call-template>
                    </identifier>
                </relatedItem>
            </xsl:when>
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Handling image records that are compound children requires two templates. This template tests: If 
         the record has no non-image siblings and is to become a book page, the relationship type is changed 
         from isChildOf to isPageOf, otherwise it is copied through.
         A subsequent template handles removal of the collection relationship if a record is changed to a
         book page.
    -->
    <xsl:template match="mods:mods[mods:relatedItem[@otherType = 'isChildOf']][matches(mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier,'image')]/mods:relatedItem[@otherType = 'isChildOf']" exclude-result-prefixes="#all">
        <xsl:variable name="identifier" select="parent::mods:mods/mods:identifier[@type = 'islandora']"/>
        <xsl:variable name="book-identifier" select="normalize-space(mods:identifier)"/>
        <xsl:choose>
            <xsl:when test="$tree//node[@id = $identifier][not(parent::node/node[@cmodel = 'islandora:collectionCModel'])][not(parent::node/node[not(matches(@cmodel,'image'))])]">
                <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="isPageOf" otherTypeAuth="dgi">
                    <identifier>
                        <xsl:call-template name="book-identifier">
                            <xsl:with-param name="book-identifier" select="$book-identifier"/>
                        </xsl:call-template>
                    </identifier>
                </relatedItem>
            </xsl:when>
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- See preceding template. This template, which also addresses compound children, tests: 
        If the record has no non-image siblings and is to become a book page, the relationship
        to a collection is removed, otherwise it is copied through.  -->
    <xsl:template match="mods:mods[mods:relatedItem[@otherType = 'isChildOf']][matches(mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier,'image')]/mods:relatedItem[@otherType = 'islandoraCollection']" exclude-result-prefixes="#all">
        <xsl:variable name="identifier" select="parent::mods:mods/mods:identifier[@type = 'islandora']"/>
        <xsl:variable name="book-identifier" select="normalize-space(mods:identifier)"/>
        <xsl:choose>
            <xsl:when test="$tree//node[@id = $identifier][not(parent::node/node[@cmodel = 'islandora:collectionCModel'])][not(parent::node/node[not(matches(@cmodel,'image'))])]"/>
            <!-- or let it be -->
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="book-identifier">
        <xsl:param name="book-identifier" as="xs:string" required="yes"/>
        <xsl:choose>
            <xsl:when test="contains($book-identifier,':')">
                <xsl:value-of select="substring-after($book-identifier,':')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$book-identifier"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- have to change cModel for the image objects that will become pages 
         this works for both compounds and collections
    -->
    <xsl:template match="mods:mods/mods:relatedItem[@otherType = 'islandoraCModel'][mods:identifier[matches(.,'image')]]" exclude-result-prefixes="#all">
        <xsl:variable name="identifier" select="parent::mods:mods/mods:identifier[@type = 'islandora']"/>
        <xsl:variable name="book-identifier" select="parent::mods:mods/mods:relatedItem[@otherType = 'islandoraCollection']/mods:identifier"/>
        <xsl:choose>
            <!-- when: parent is a container, does not have any subcollections, and none of its children are not images, 
                 it's a page so replace child relationship with collection to isPageOf -->
            <xsl:when test="$tree//node[@id = $identifier][not(parent::node/node[@cmodel = 'islandora:collectionCModel'])][not(parent::node/node[not(matches(@cmodel,'image'))])]">
                <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="islandoraCModel" otherTypeAuth="dgi">
                    <identifier>islandora:pageCModel</identifier>
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
