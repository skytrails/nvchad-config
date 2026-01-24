<!-- CircleAvatar.vue -->
<template>
  <div
    class="simple-avatar"
    :style="avatarStyle"
    @click="$emit('click')"
  >
    {{ firstChar }}
  </div>
</template>

<script>
export default {
  name: 'CircleAvatar',

  props: {
    text: {
      type: String,
      default: 'U'
    },
    size: {
      type: [Number, String],
      default: 40
    },
    color: {
      type: String,
      default: null
    }
  },

  computed: {
    firstChar() {
      const trimmed = this.text.trim()
      return trimmed ? trimmed.charAt(0).toUpperCase() : 'U'
    },

    avatarStyle() {
      const sizePx = `${this.size}px`
      const fontSize = `${Math.floor(this.size * 0.4)}px`

      // 生成固定颜色或使用指定颜色
      const bgColor = this.color || this.getFixedColor(this.text)

      return {
        width: sizePx,
        height: sizePx,
        lineHeight: sizePx,
        fontSize: fontSize,
        backgroundColor: bgColor,
        color: '#ffffff',
        borderRadius: '50%',
        textAlign: 'center',
        fontWeight: 'bold',
        cursor: 'pointer',
        userSelect: 'none',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
      }
    }
  },

  methods: {
    // 简单的字符串哈希函数
    hashString(str) {
      let hash = 0
      for (let i = 0; i < str.length; i++) {
        hash = str.charCodeAt(i) + ((hash << 5) - hash)
      }
      return hash
    },

    // 根据字符串获取固定颜色
    getFixedColor(str) {
      const colors = [
        '#f44336', '#e91e63', '#9c27b0', '#673ab7',
        '#3f51b5', '#2196f3', '#03a9f4', '#00bcd4',
        '#009688', '#4caf50', '#8bc34a', '#cddc39',
        '#ffeb3b', '#ffc107', '#ff9800', '#ff5722'
      ]

      // 如果字符串为空，使用默认颜色
      if (!str || str.trim() === '') {
        return colors[0]
      }

      // 计算哈希值并映射到颜色数组
      const hash = this.hashString(str.trim().toLowerCase())
      const index = Math.abs(hash) % colors.length
      return colors[index]
    }
  }
}
</script>
