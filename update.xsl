<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:variable name="data" select="document('data.xml')"/>
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="items">
    <xsl:copy>
      <xsl:variable name="id" select="../id"/>
      <xsl:for-each select="item">
        <xsl:variable name="tt" select="type"/>
        <xsl:choose>
          <xsl:when test="type = 'Generic function'">
          <item>
          <type>Generic function</type>
          <page><xsl:value-of select="$data//entry[id = $id and type = 'Primary method']/page"/></page>
          </item>
          </xsl:when>
        <xsl:otherwise>
        <item>
          <type><xsl:value-of select="$tt"/></type>
          <page><xsl:value-of select="sort($data//entry[id = $id and type = $tt]/page)" separator=", "/></page>
        </item>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
