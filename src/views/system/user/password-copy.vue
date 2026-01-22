<!-- 用户编辑弹窗 -->
<template>
  <el-dialog
    width="680px"
    :visible="visible"
    :lock-scroll="false"
    :destroy-on-close="true"
    custom-class="copy-dialog"
    title="复制密码"
    @update:visible="updateVisible"
  >
    <!-- 内容区 -->
    <div class="copy-content">
      <div class="copy-text">
        {{ data }}
      </div>
    </div>
    <div slot="footer">
      <el-button @click="updateVisible(false)">取消 </el-button>
      <el-button type="primary" @click="copy">复制 </el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: "UserEdit",
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: String,
  },
  components: {},
  data() {
    return {};
  },
  methods: {
    /* 保存编辑 */
    async copy() {
      try {
        await navigator.clipboard.writeText(this.data);
        this.$message({ type: "success", message: "已复制到剪贴板" });
      } catch (e) {
        this.$message({ type: "success", message: "复制失败" });
      }
    },
    /* 更新visible */
    updateVisible(value) {
      this.$emit("update:visible", value);
    },
  },
};
</script>

<style scoped>
/* 弹窗 body 居中 */
.copy-dialog .el-dialog__body {
  padding: 30px;
}

/* 内容容器 */
.copy-content {
  display: flex;
  align-items: center; /* 垂直居中 */
  justify-content: center; /* 水平居中 */
  min-height: 120px;
}

/* 文本样式 */
.copy-text {
  max-width: 100%;
  padding: 16px 24px;
  font-size: 18px;
  font-weight: 500;
  letter-spacing: 2px;
  text-align: center;
  word-break: break-all;

  background-color: #f5f7fa;
  border: 1px dashed #409eff;
  border-radius: 6px;
  color: #303133;
  cursor: pointer;
}

/* hover 提示可复制 */
.copy-text:hover {
  background-color: #f0f7ff;
  border-color: #409eff;
}
</style>
