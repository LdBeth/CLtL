<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="items">
    <xsl:variable name="self">
      <xsl:copy-of select="."/>
    </xsl:variable>
    <xsl:variable name="tmp">
      <xsl:for-each select="item">
        <xsl:sort select="type"/>
        <item>
          <type><xsl:value-of select="type"/></type>
          <page><xsl:value-of select="sort($self//item[type = type]/page)" separator=", "/></page>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <items>
    <xsl:for-each select="$tmp/item">
    <xsl:variable name="pos" select="position()"/>
    <xsl:if test="$pos = 1 or 
                  not(deep-equal(. , preceding-sibling::*[1]))">
      <xsl:copy-of select="."/>
    </xsl:if>
    </xsl:for-each>
    </items>
  </xsl:template>
</xsl:stylesheet>
