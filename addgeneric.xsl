<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="items">
    <xsl:copy>
      <xsl:for-each select="item">
        <xsl:if test="type = 'Primary method'">
          <item>
          <type>Generic function</type>
          <page><xsl:value-of select="page"/></page>
        </item>
        </xsl:if>
        <item>
          <type><xsl:value-of select="type"/></type>
          <page><xsl:value-of select="page"/></page>
        </item>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
