<!-- 文章编辑弹窗 -->
<template>
  <el-drawer
    class="cdk-edit-drawer"
    :title="drawerTitle"
    :visible.sync="showDrawer"
    :direction="direction"
    :size="isMobile ? '100%' : '550px'"
    :wrapperClosable="false"
    :before-close="handleClose"
    @open="onDrawerOpen"
  >
    <div class="drawer-content">
      <el-alert
        v-if="showTips"
        title="使用说明"
        type="info"
        :closable="false"
        show-icon
        class="mb-20"
      >
        <p>1. 输入游戏ID和生成数量</p>
        <p>2. 生成后可在CDK列表中查看和导出</p>
      </el-alert>

      <el-form
        ref="form"
        :model="form"
        :rules="rules"
        label-width="120px"
        label-position="top"
        class="cdk-form"
        @submit.native.prevent
      >
        <el-card shadow="never" class="form-card">
          <div slot="header" class="form-card-header">
            <span class="header-title">
              <i class="el-icon-tickets"></i>
              生成设置
            </span>
          </div>

          <div class="form-card-body">
            <!-- 游戏ID -->
            <el-form-item label="游戏ID" prop="gameId" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <i class="el-icon-video-game"></i>
                  游戏ID
                  <el-tooltip content="请输入Steam游戏AppID" placement="top">
                    <i class="el-icon-question"></i>
                  </el-tooltip>
                </span>
              </template>
              <el-input
                v-model="form.gameId"
                placeholder="请输入游戏AppID"
                clearable
                :prefix-icon="'el-icon-video-game'"
                size="medium"
                @keyup.enter.native="handleGenerate"
              >
                <template #append>
                  <el-button
                    type="text"
                    @click="showGameList = true"
                    class="select-game-btn"
                  >
                    选择游戏
                  </el-button>
                </template>
              </el-input>
            </el-form-item>

            <!-- 生成数量 -->
            <el-form-item label="生成数量" prop="count" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <i class="el-icon-collection"></i>
                  生成数量
                </span>
              </template>
              <div class="count-input-container">
                <el-input-number
                  v-model="form.count"
                  :min="1"
                  :max="10000"
                  :step="1"
                  :precision="0"
                  placeholder="请输入数量"
                  controls-position="right"
                  size="medium"
                  style="width: 100%"
                />
                <div class="count-tips">
                  <span class="count-tip" @click="quickSetCount(10)">10个</span>
                  <span class="count-tip" @click="quickSetCount(50)">50个</span>
                  <span class="count-tip" @click="quickSetCount(100)">100个</span>
                </div>
              </div>
            </el-form-item>

            <!-- 备注 -->
            <el-form-item label="备注" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <i class="el-icon-edit"></i>
                  备注信息
                  <el-tooltip content="可选，用于说明这批CDK的用途" placement="top">
                    <i class="el-icon-question"></i>
                  </el-tooltip>
                </span>
              </template>
              <el-input
                v-model="form.description"
                type="textarea"
                :rows="3"
                placeholder="请输入备注信息，最多200字"
                maxlength="200"
                show-word-limit
                resize="none"
                size="medium"
              />
            </el-form-item>

            <!-- 高级设置（可折叠） -->
            <el-collapse v-model="activeCollapse" class="advanced-settings">
              <el-collapse-item title="高级设置" name="1">
                <template #title>
                  <i class="el-icon-setting"></i>
                  <span>高级设置</span>
                </template>

                <el-form-item label="有效期" class="form-item-with-icon">
                  <template #label>
                    <span class="form-label">
                      <i class="el-icon-timer"></i>
                      有效期
                    </span>
                  </template>
                  <el-date-picker
                    v-model="form.expiryDate"
                    type="date"
                    placeholder="选择过期日期（可选）"
                    :picker-options="datePickerOptions"
                    format="yyyy-MM-dd"
                    value-format="yyyy-MM-dd"
                    size="medium"
                    style="width: 100%"
                  />
                </el-form-item>

                <el-form-item label="使用次数限制" class="form-item-with-icon">
                  <template #label>
                    <span class="form-label">
                      <i class="el-icon-refresh"></i>
                      使用次数限制
                    </span>
                  </template>
                  <el-radio-group v-model="form.useLimitType" size="medium">
                    <el-radio :label="1">单次使用</el-radio>
                    <el-radio :label="0">无限制</el-radio>
                  </el-radio-group>
                </el-form-item>
              </el-collapse-item>
            </el-collapse>
          </div>
        </el-card>

        <!-- 操作按钮 -->
        <div class="form-actions">
          <el-button
            type="primary"
            :loading="loading"
            :disabled="!form.gameId || !form.count"
            @click="handleGenerate"
            size="medium"
            class="generate-btn"
          >
            <i class="el-icon-magic-stick"></i>
            {{ loading ? '生成中...' : '生成CDK' }}
          </el-button>

          <el-button
            @click="handleReset"
            size="medium"
            class="reset-btn"
          >
            <i class="el-icon-refresh-left"></i>
            重置
          </el-button>

          <el-button
            @click="$emit('close')"
            size="medium"
            plain
          >
            <i class="el-icon-close"></i>
            取消
          </el-button>
        </div>

        <!-- 进度提示 -->
        <div v-if="loading" class="progress-hint">
          <el-progress
            :percentage="progress"
            :stroke-width="4"
            :show-text="false"
            :indeterminate="progress === 0"
          />
          <p class="hint-text">正在生成CDK，请稍候...</p>
        </div>
      </el-form>

      <!-- 游戏选择对话框 -->
      <el-dialog
        v-if="showGameList"
        title="选择游戏"
        :visible.sync="showGameList"
        width="800px"
        @close="showGameList = false"
        class="game-select-dialog"
      >
        <!-- 这里可以添加游戏列表组件 -->
        <div class="game-list-placeholder">
          <p>游戏列表功能待实现</p>
          <el-button type="text" @click="showGameList = false">关闭</el-button>
        </div>
      </el-dialog>
    </div>
  </el-drawer>
</template>

<script>
export default {
  name: "CdkEdit",
  props: {
    visible: Boolean,
    data: Object,
    cateList: Array,
  },
  data() {
    return {
      showDrawer: this.visible,
      direction: "rtl",
      form: {
        gameId: '',
        count: 1,
        description: '',
        expiryDate: '',
        useLimitType: 1
      },
      rules: {
        gameId: [
          { required: true, message: "请输入游戏ID", trigger: "blur" },
          { pattern: /^\d+$/, message: "游戏ID必须为数字", trigger: "blur" }
        ],
        count: [
          { required: true, message: "请输入CDK数量", trigger: "blur" },
          { type: 'number', min: 1, max: 10000, message: "数量范围1-10000", trigger: "blur" }
        ]
      },
      loading: false,
      isUpdate: false,
      progress: 0,
      showGameList: false,
      activeCollapse: [],
      showTips: true,
      datePickerOptions: {
        disabledDate(time) {
          return time.getTime() < Date.now();
        }
      }
    };
  },
  computed: {
    drawerTitle() {
      return this.isUpdate ? '编辑CDK' : '生成CDK';
    },
    isMobile() {
      return window.innerWidth < 768;
    }
  },
  watch: {
    visible(val) {
      this.showDrawer = val;
      if (val) {
        this.$nextTick(() => {
          this.resetForm();
        });
      }
    },
    data: {
      handler(val) {
        if (val) {
          this.form = { ...this.form, ...val };
          this.isUpdate = true;
        } else {
          this.resetForm();
          this.isUpdate = false;
        }
      },
      immediate: true
    }
  },
  methods: {
    /* 快速设置数量 */
    quickSetCount(num) {
      this.form.count = num;
      this.$forceUpdate();
    },

    /* 重置表单 */
    handleReset() {
      this.$refs.form.resetFields();
      this.form.description = '';
      this.form.expiryDate = '';
      this.form.useLimitType = 1;
      this.activeCollapse = [];
    },

    /* 保存编辑 */
    handleGenerate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.loading = true;
          this.progress = 0;

          // 模拟进度
          const progressTimer = setInterval(() => {
            if (this.progress < 90) {
              this.progress += 10;
            }
          }, 300);

          this.$http
            .post("/cdk/generate", { ...this.form })
            .then((res) => {
              clearInterval(progressTimer);
              this.progress = 100;

              setTimeout(() => {
                this.loading = false;
                if (res.data.code === 200) {
                  this.$message.success({
                    message: res.data.message,
                    showClose: true,
                    duration: 3000
                  });

                  if (!this.isUpdate) {
                    this.handleReset();
                  }
                  this.updateVisible(false);
                  this.$emit("done");
                } else {
                  this.$message.error({
                    message: res.data.message,
                    showClose: true
                  });
                }
                this.progress = 0;
              }, 500);
            })
            .catch((e) => {
              clearInterval(progressTimer);
              this.loading = false;
              this.progress = 0;
              this.$message.error({
                message: e.message || "生成失败",
                showClose: true
              });
            });
        } else {
          return false;
        }
      });
    },

    /* 重置表单数据 */
    resetForm() {
      this.form = {
        gameId: '',
        count: 1,
        description: '',
        expiryDate: '',
        useLimitType: 1
      };
      this.activeCollapse = [];
    },

    /* 抽屉打开时的回调 */
    onDrawerOpen() {
      this.$nextTick(() => {
        if (this.$refs.form) {
          this.$refs.form.clearValidate();
        }
        if (this.form.gameId) {
          this.$refs.form.focus && this.$refs.form.focus();
        }
      });
    },

    /* 处理关闭 */
    handleClose(done) {
      if (this.loading) {
        this.$confirm('CDK正在生成中，确定要关闭吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning',
          center: true
        }).then(() => {
          this.loading = false;
          done();
        });
      } else {
        done();
      }
    },

    /* 更新visible */
    updateVisible(value) {
      this.$emit("update:visible", value);
    },

    /* 关闭页面 */
    close(hide) {
      this.handleClose(() => {
        if (hide) hide();
        this.$emit("done");
      });
    }
  }
};
</script>

<style lang="scss" scoped>
.cdk-edit-drawer {
  // 自定义滚动条
  ::v-deep .el-drawer__body {
    padding: 0;
    overflow-y: auto;

    &::-webkit-scrollbar {
      width: 6px;
    }

    &::-webkit-scrollbar-track {
      background: #f5f5f5;
    }

    &::-webkit-scrollbar-thumb {
      background: #c1c1c1;
      border-radius: 3px;

      &:hover {
        background: #a8a8a8;
      }
    }
  }

  ::v-deep .el-drawer__header {
    margin-bottom: 0;
    padding: 20px;
    border-bottom: 1px solid #f0f0f0;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;

    span {
      font-size: 18px;
      font-weight: 600;
    }

    .el-drawer__close-btn {
      color: white;

      &:hover {
        color: rgba(255, 255, 255, 0.8);
      }
    }
  }
}

.drawer-content {
  padding: 20px;
  min-height: 100%;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

// 卡片样式
.form-card {
  border-radius: 12px;
  border: 1px solid #e4e7ed;
  margin-bottom: 24px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;

  &:hover {
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  }

  .form-card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #f0f0f0;
    padding: 16px 20px;
    background: #fafafa;
    border-radius: 12px 12px 0 0;

    .header-title {
      font-size: 16px;
      font-weight: 600;
      color: #333;

      i {
        margin-right: 8px;
        color: #409eff;
      }
    }
  }

  .form-card-body {
    padding: 24px;
  }
}

// 表单样式
.cdk-form {
  .form-item-with-icon {
    margin-bottom: 24px;

    .form-label {
      display: flex;
      align-items: center;
      font-weight: 500;
      color: #606266;

      i:first-child {
        margin-right: 8px;
        color: #409eff;
      }

      .el-icon-question {
        margin-left: 4px;
        color: #c0c4cc;
        cursor: help;
        transition: color 0.3s;

        &:hover {
          color: #409eff;
        }
      }
    }
  }

  ::v-deep .el-input,
  ::v-deep .el-textarea {
    .el-input__inner,
    .el-textarea__inner {
      border-radius: 8px;
      transition: all 0.3s;
      border: 1px solid #dcdfe6;

      &:focus {
        border-color: #409eff;
        box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
      }
    }
  }
}

// 数量输入容器
.count-input-container {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .count-tips {
    display: flex;
    gap: 12px;
    margin-top: 4px;

    .count-tip {
      padding: 2px 8px;
      background: #ecf5ff;
      border-radius: 4px;
      color: #409eff;
      font-size: 12px;
      cursor: pointer;
      transition: all 0.3s;

      &:hover {
        background: #409eff;
        color: white;
        transform: translateY(-1px);
      }

      &:active {
        transform: translateY(0);
      }
    }
  }
}

// 选择游戏按钮
.select-game-btn {
  color: #409eff !important;
  font-size: 12px;
  padding: 0 8px;

  &:hover {
    color: #66b1ff !important;
  }
}

// 高级设置
.advanced-settings {
  margin-top: 24px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  overflow: hidden;

  ::v-deep .el-collapse-item__header {
    padding: 0 16px;
    background: #fafafa;
    font-weight: 500;
    color: #333;
    border-bottom: 1px solid #e4e7ed;

    i {
      margin-right: 8px;
      color: #409eff;
    }
  }

  ::v-deep .el-collapse-item__content {
    padding: 16px;
  }
}

// 操作按钮区域
.form-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 32px;
  padding: 24px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

  .generate-btn {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    padding: 12px 36px;
    font-weight: 500;
    letter-spacing: 1px;

    &:hover {
      background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
    }

    &:active {
      transform: translateY(0);
    }

    &:disabled {
      background: #c0c4cc;
      cursor: not-allowed;

      &:hover {
        transform: none;
        box-shadow: none;
      }
    }
  }

  .reset-btn {
    color: #f56c6c;
    border-color: #f56c6c;

    &:hover {
      color: white;
      background: #f56c6c;
    }
  }
}

// 进度提示
.progress-hint {
  margin-top: 24px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  text-align: center;

  .hint-text {
    margin-top: 12px;
    color: #909399;
    font-size: 14px;
  }
}

// 游戏选择对话框
.game-select-dialog {
  ::v-deep .el-dialog__header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

    .el-dialog__title,
    .el-dialog__close {
      color: white;
    }
  }

  .game-list-placeholder {
    text-align: center;
    padding: 40px;
    color: #909399;

    p {
      margin-bottom: 16px;
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .drawer-content {
    padding: 16px;
  }

  .form-card {
    .form-card-body {
      padding: 16px;
    }
  }

  .form-actions {
    flex-direction: column;
    gap: 12px;

    button {
      width: 100%;
    }
  }

  .count-input-container {
    .count-tips {
      justify-content: center;
    }
  }
}

// 动画效果
@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

.generate-btn:not(:disabled):hover {
  animation: pulse 0.6s ease-in-out;
}

// 美化El-Alert
::v-deep .el-alert {
  border-radius: 8px;
  border: 1px solid #ebeef5;

  &.el-alert--info {
    background-color: #f4f4f5;
    color: #909399;
  }

  .el-alert__title {
    font-weight: 600;
  }

  .el-alert__content {
    p {
      margin: 4px 0;
      font-size: 13px;
    }
  }
}

.mb-20 {
  margin-bottom: 20px;
}
</style>
