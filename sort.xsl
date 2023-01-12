<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   
  <xsl:template match="/">
     
    <xsl:variable name="products">
      <xsl:for-each select="//entry">
        <xsl:sort select="id"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>
     
    <index>
  <xsl:for-each select="$products/entry">
    <xsl:variable name="pos" select="position()"/>
    <xsl:if test="$pos = 1 or 
                  not(deep-equal(. , preceding-sibling::entry[1]))">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:for-each>
</index>
     
  </xsl:template>
</xsl:stylesheet>
