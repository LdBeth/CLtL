<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:data="_local.uri"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <data:typemap>
        <entry key="breve">9</entry>
        <entry key="whole">0</entry>
        <entry key="half">2</entry>
        <entry key="quarter">4</entry>
        <entry key="eighth">8</entry>
        <entry key="16th">1</entry>
        <entry key="32nd">3</entry>
        <entry key="64th">6</entry>
  </data:typemap>
  <xsl:template match="/">
    <xsl:apply-templates select="score-partwise/part"/>
  </xsl:template>
  <xsl:template match="part">
    <xsl:for-each select="measure">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="measure">
    <xsl:text>% measure </xsl:text>
    <xsl:value-of select="@number" />
    <xsl:text>&#xA;</xsl:text>
    <xsl:for-each select="note">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    <xsl:text>/&#xA;</xsl:text>
  </xsl:template>
  <xsl:template match="note">
    <xsl:variable name="_ntype" select="type"/>
    <xsl:variable name="ntype" select="document('')/xsl:stylesheet/data:typemap/entry[@key=$_ntype]"/>
    <xsl:if test="tie[@type='start']">
      <xsl:text>( </xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="rest">
        <xsl:text>r</xsl:text>
        <xsl:value-of select="$ntype"/>
      </xsl:when>
      <xsl:when test="chord">
        <xsl:text>z</xsl:text>
        <xsl:value-of select='translate(pitch/step,"ABCDEFG", "abcdefg")'/>
        <xsl:value-of select="pitch/octave"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select='translate(pitch/step,"ABCDEFG", "abcdefg")'/>
        <xsl:value-of select="$ntype"/>
        <xsl:value-of select="pitch/octave"/>
        <xsl:if test="accidental">
          <xsl:value-of select="substring(accidental, 1, 1)"/>
        </xsl:if>
        <xsl:if test="dot">
          <xsl:text>d</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:if test="tie[@type='stop']">
      <xsl:text>) </xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
