<!-- CDK生成弹窗 -->
<template>
  <el-drawer class="cdk-edit-drawer" :title="drawerTitle" :visible.sync="showDrawer" :direction="direction"
    :size="isMobile ? '100%' : '650px'" :wrapperClosable="false" :before-close="handleClose" @open="onDrawerOpen">
    <div class="drawer-content">
      <el-alert v-if="showTips" title="使用说明" type="info" :closable="true" @close="showTips = false" show-icon
        class="mb-20">
        <p>1. 输入或搜索游戏，快速选择游戏ID</p>
        <p>2. 设置生成数量和其他选项</p>
        <p>3. 生成后可在CDK列表中查看和导出</p>
      </el-alert>

      <el-form ref="form" :model="form" :rules="rules" label-width="120px" label-position="top" class="cdk-form"
        @submit.native.prevent>
        <el-card shadow="never" class="form-card">
          <div slot="header" class="form-card-header">
            <span class="header-title">
              <i class="el-icon-tickets"></i>
              生成设置
            </span>
          </div>

          <div class="form-card-body">
            <!-- 游戏搜索和选择 -->
            <el-form-item label="选择游戏" prop="gameId" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <i class="el-icon-video-game"></i>
                  选择游戏
                  <el-tooltip content="输入游戏名称或AppID进行搜索" placement="top">
                    <i class="el-icon-question"></i>
                  </el-tooltip>
                </span>
              </template>

              <div class="game-search-container">
                <!-- 搜索输入框 -->
                <el-autocomplete v-model="searchKeyword" class="game-search-input" :fetch-suggestions="querySearchAsync"
                  :trigger-on-focus="false" placeholder="搜索游戏名称或AppID" @select="handleGameSelect"
                  @clear="handleSearchClear" clearable size="medium">
                  <template #prefix>
                    <i class="el-icon-search"></i>
                  </template>

                  <template #default="{ item }">
                    <div class="game-suggestion-item">
                      <div class="game-info">
                        <div class="game-name">{{ item.name }}</div>
                        <div class="game-details">
                          <el-tag class="game-tag" size="max">
                            <span class="game-name" style="color: #409eff; font-size: 16px;">{{ item.gameName }}</span>
                            <span class="separator" style="color: #113300;"> - </span>
                            <span class="game-id" style="color: #67c23a; font-size: 16px;">{{ item.gameId }}</span>
                          </el-tag>
                          <el-tag size="mini" :type="getGameStatusType(item.status)" class="ml-8">
                            {{ getGameStatusTag(item.status) }}
                          </el-tag>
                        </div>
                      </div>
                      <div class="game-actions">
                        <el-button type="text" size="mini" @click.stop="selectGame(item)" class="select-btn">
                          选择
                        </el-button>
                      </div>
                    </div>
                  </template>
                </el-autocomplete>

                <!-- 已选择的游戏信息 -->
                <div v-if="selectedGame" class="selected-game-card">
                  <div class="selected-game-header">
                    <span class="selected-title">已选择游戏</span>
                    <el-button type="text" size="mini" @click="clearSelection" class="clear-btn">
                      清空
                    </el-button>
                  </div>
                  <div class="selected-game-content">
                    <div class="game-icon">
                      <img v-if="selectedGame.image" :src="selectedGame.image" :alt="selectedGame.gameName"
                        @error="handleImageError" />
                      <circle-avatar v-else :text="selectedGame.gameName" size="64" />
                    </div>
                    <div class="game-details">
                      <div class="game-name">{{ selectedGame.gameName }}</div>
                      <div class="game-meta">
                        <el-tag size="small" type="info" class="mr-8">
                          AppID: {{ selectedGame.gameId }}
                        </el-tag>
                        <span v-if="selectedGame.updatedAt" class="release-date">
                          {{ formatDate(selectedGame.updatedAt) }}
                        </span>
                      </div>
                      <div v-if="selectedGame.short_description" class="game-description">
                        {{ selectedGame.short_description }}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
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
                <el-input-number v-model="form.count" :min="1" :max="10000" :step="1" :precision="0" placeholder="请输入数量"
                  controls-position="right" size="medium" style="width: 100%" />
                <div class="count-tips">
                  <span class="count-tip" @click="quickSetCount(10)">10个</span>
                  <span class="count-tip" @click="quickSetCount(50)">50个</span>
                  <span class="count-tip" @click="quickSetCount(100)">100个</span>
                  <span class="count-tip" @click="quickSetCount(500)">500个</span>
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
              <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入备注信息，最多200字"
                maxlength="200" show-word-limit resize="none" size="medium" />
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
                  <el-date-picker v-model="form.expiryDate" type="date" placeholder="选择过期日期（可选）"
                    :picker-options="datePickerOptions" format="yyyy-MM-dd" value-format="yyyy-MM-dd" size="medium"
                    style="width: 100%" />
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
          <el-button type="primary" :loading="loading" :disabled="!form.gameId || !form.count" @click="handleGenerate"
            size="medium" class="generate-btn">
            <i class="el-icon-magic-stick"></i>
            {{ loading ? '生成中...' : '生成CDK' }}
          </el-button>

          <el-button @click="handleReset" size="medium" class="reset-btn">
            <i class="el-icon-refresh-left"></i>
            重置
          </el-button>

          <el-button @click="$emit('close')" size="medium" plain>
            <i class="el-icon-close"></i>
            取消
          </el-button>
        </div>

        <!-- 进度提示 -->
        <div v-if="loading" class="progress-hint">
          <el-progress :percentage="progress" :stroke-width="4" :show-text="false" :indeterminate="progress === 0" />
          <p class="hint-text">正在生成CDK，请稍候...</p>
        </div>
      </el-form>
    </div>
  </el-drawer>
</template>

<script>
import CircleAvatar from '@/components/CircleAvatar.vue';

export default {
  name: "CdkEdit",
  components: { CircleAvatar },
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
          { required: true, message: "请选择游戏或输入游戏ID", trigger: "blur" },
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
      searchKeyword: '',
      searchLoading: false,
      selectedGame: null,
      activeCollapse: [],
      showTips: true,
      datePickerOptions: {
        disabledDate(time) {
          return time.getTime() < Date.now();
        }
      },
      searchTimeout: null
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
          // 如果有游戏ID，尝试查找游戏信息
          if (val.gameId && !this.selectedGame) {
            this.searchGameById(val.gameId);
          }
        } else {
          this.resetForm();
          this.isUpdate = false;
        }
      },
      immediate: true
    }
  },
  methods: {
    /* 异步搜索游戏 */
    querySearchAsync(queryString, cb) {
      if (!queryString || queryString.trim().length < 2) {
        cb([]);
        return;
      }

      // 清除之前的定时器
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout);
      }

      // 设置防抖
      this.searchTimeout = setTimeout(async () => {
        try {
          this.searchLoading = true;
          const response = await this.$http.get('/game/search', {
            params: {
              keyword: queryString.trim(),
              limit: 10 // 限制返回数量
            }
          });

          if (response.data.code === 200) {
            const games = response.data.data || [];
            // 格式化数据用于autocomplete
            const suggestions = games.map(game => ({
              value: `${game.gameName} (${game.gameId})`,
              ...game
            }));
            cb(suggestions);
          } else {
            cb([]);
          }
        } catch (error) {
          console.error('搜索游戏失败:', error);
          cb([]);
        } finally {
          this.searchLoading = false;
        }
      }, 300); // 300ms防抖
    },

    /* 根据ID搜索游戏 */
    async searchGameById(gameId) {
      if (!gameId) return;

      try {
        const response = await this.$http.get('/game/search', {
          params: {
            keyword: gameId,
            exact: true // 精确匹配
          }
        });

        if (response.data.code === 200 && response.data.data && response.data.data.length > 0) {
          this.selectedGame = response.data.data[0];
        }
      } catch (error) {
        console.error('根据ID搜索游戏失败:', error);
      }
    },

    /* 选择游戏 */
    handleGameSelect(item) {
      this.selectGame(item);
    },

    /* 选择游戏（内部方法） */
    selectGame(game) {
      this.selectedGame = game;
      this.form.gameId = game.gameId;
      this.searchKeyword = ''; // 清空搜索框

      // 清除表单验证
      this.$refs.form.clearValidate('gameId');
    },

    /* 清空选择 */
    clearSelection() {
      this.selectedGame = null;
      this.form.gameId = '';
      this.searchKeyword = '';
    },

    /* 手动输入处理 */
    handleManualInput(value) {
      if (value && this.selectedGame && this.selectedGame.gameId !== value) {
        this.selectedGame = null;
      }
      this.searchKeyword = '';
    },

    /* 清除搜索 */
    handleSearchClear() {
      this.searchKeyword = '';
    },

    /* 处理图片加载失败 */
    handleImageError(event) {
      event.target.style.display = 'none';
      const placeholder = event.target.parentNode.querySelector('.game-icon-placeholder');
      if (placeholder) {
        placeholder.style.display = 'flex';
      }
    },

    /* 获取游戏类型标签样式 */
    getGameStatusType(type) {
      const typeMap = {
        0: 'warning',
        1: 'success',
      };
      return typeMap[type] || 'info';
    },
    getGameStatusTag(type) {
      const typeMap = {
        0: '禁用',
        1: '启用',
      };
      return typeMap[type] || '禁用';
    },

    /* 格式化日期 */
    formatDate(dateString) {
      if (!dateString) return '';
      try {
        return new Date(dateString).toLocaleDateString('zh-CN');
      } catch {
        return dateString;
      }
    },

    /* 快速设置数量 */
    quickSetCount(num) {
      this.form.count = num;
      this.$forceUpdate();
    },

    /* 重置表单 */
    handleReset() {
      this.$refs.form.resetFields();
      this.clearSelection();
      this.form.description = '';
      this.form.expiryDate = '';
      this.form.useLimitType = 1;
      this.activeCollapse = [];
      this.searchKeyword = '';
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
      this.selectedGame = null;
      this.searchKeyword = '';
      this.activeCollapse = [];
    },

    /* 抽屉打开时的回调 */
    onDrawerOpen() {
      this.$nextTick(() => {
        if (this.$refs.form) {
          this.$refs.form.clearValidate();
        }
      });
    },

    /* 处理关闭 */
    handleClose() {
      if (this.loading) {
        this.$confirm('CDK正在生成中，确定要关闭吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning',
          center: true
        }).then(() => {
          this.loading = false;
          this.$emit("done");
        });
      } else {
        this.$emit("done");
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
  },
  beforeDestroy() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
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
    background: linear-gradient(135deg, #f1f4f9 0%, #dbe2ef 0%);
    box-shadow: 0 1px 2px rgba(0, 0, 0, 1);
    color: #303133;

    span {
      font-size: 18px;
      font-weight: 600;
      color: #303133;
    }

    .el-drawer__close-btn {
      color: #909399;

      &:hover {
        color: #606266;
      }
    }
  }
}

.drawer-content {
  padding: 20px;
  min-height: 100%;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  background: #f1f4f9;
}

// 卡片样式
.form-card {
  border-radius: 8px;
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

// 游戏搜索容器
.game-search-container {
  .game-search-input {
    width: 100%;
    margin-bottom: 16px;

    ::v-deep .el-input__inner {
      border-radius: 6px;
      padding-left: 36px;
    }

    ::v-deep .el-input__prefix {
      display: flex;
      align-items: center;
      left: 12px;
      color: #909399;
    }
  }

  // 游戏建议项
  .game-suggestion-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 12px;
    width: 100%;

    &:hover {
      background-color: #f5f7fa;
    }

    .game-info {
      flex: 1;
      min-width: 0;

      .game-name {
        font-weight: 500;
        color: #303133;
        margin-bottom: 4px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }


      .game-details {
        ::v-deep .game-tag {
          background: linear-gradient(135deg, #f6f6f6 0%, #fafafa 100%);
          border: 1px solid #e4e7ed;
          border-radius: 4px;
          padding: 0 8px;
          height: 24px;
          line-height: 22px;

          .el-tag__content {
            display: flex;
            align-items: center;
            gap: 4px;
          }

          .game-name {
            color: #409eff;
            font-weight: 500;
            font-size: 12px;
          }

          .separator {
            color: #dcdfe6;
            margin: 0 2px;
            font-weight: bold;
          }

          .game-id {
            color: #67c23a;
            font-weight: 600;
            background: rgba(103, 194, 58, 0.1);
            padding: 1px 4px;
            border-radius: 2px;
            font-size: 11px;
          }
        }
      }
    }

    .game-actions {
      margin-left: 12px;

      .select-btn {
        color: #409eff;
        padding: 2px 8px;

        &:hover {
          background-color: #ecf5ff;
          border-radius: 4px;
        }
      }
    }
  }
}

// 已选择的游戏卡片
.selected-game-card {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  margin: 16px 0;
  overflow: hidden;
  background: #ffffff;

  .selected-game-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    background: #fafafa;
    border-bottom: 1px solid #f0f0f0;

    .selected-title {
      font-size: 14px;
      font-weight: 500;
      color: #606266;
    }

    .clear-btn {
      color: #f56c6c;
      font-size: 12px;

      &:hover {
        color: #f78989;
      }
    }
  }

  .selected-game-content {
    display: flex;
    padding: 16px;

    .game-icon {
      flex-shrink: 0;
      width: 64px;
      height: 64px;
      margin-right: 16px;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 4px;
      }

      .game-icon-placeholder {
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 4px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 24px;
      }
    }

    .game-details {
      flex: 1;
      min-width: 0;

      .game-name {
        font-size: 16px;
        font-weight: 600;
        color: #303133;
        margin-bottom: 8px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .game-meta {
        display: flex;
        align-items: center;
        margin-bottom: 8px;

        .mr-8 {
          margin-right: 8px;
        }

        .release-date {
          font-size: 12px;
          color: #909399;
        }
      }

      .game-description {
        font-size: 13px;
        color: #606266;
        line-height: 1.5;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
      }
    }
  }
}

// 手动输入部分
.manual-input-section {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;

  .section-title {
    margin-bottom: 12px;

    span {
      font-size: 14px;
      font-weight: 500;
      color: #606266;
    }
  }

  .manual-input {
    ::v-deep .el-input__inner {
      border-radius: 6px;
      padding-left: 36px;
    }

    ::v-deep .el-input__prefix {
      display: flex;
      align-items: center;
      left: 12px;
      color: #909399;
    }
  }
}

// 表单样式
.cdk-form {
  .form-item-with-icon {
    margin-bottom: 20px;

    .form-label {
      display: flex;
      align-items: center;
      font-weight: 500;
      color: #606266;
      font-size: 14px;
      margin-bottom: 8px;

      i:first-child {
        margin-right: 8px;
        color: #409eff;
      }

      .el-icon-question {
        margin-left: 4px;
        color: #c0c4cc;
        cursor: help;
        transition: color 0.2s;

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
      border-radius: 6px;
      transition: all 0.2s;
      border: 1px solid #dcdfe6;
      font-size: 14px;

      &:focus {
        border-color: #409eff;
        box-shadow: 0 0 0 1px rgba(64, 158, 255, 0.2);
      }

      &:hover {
        border-color: #c0c4cc;
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
      padding: 3px 10px;
      background: #f0f7ff;
      border-radius: 4px;
      color: #409eff;
      font-size: 12px;
      cursor: pointer;
      transition: all 0.2s;
      border: 1px solid #d9ecff;

      &:hover {
        background: #409eff;
        color: white;
        border-color: #409eff;
      }

      &:active {
        transform: scale(0.98);
      }
    }
  }
}

// 高级设置
.advanced-settings {
  margin-top: 24px;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  overflow: hidden;

  ::v-deep .el-collapse-item__header {
    padding: 0 16px;
    background: #fafafa;
    font-weight: 500;
    color: #303133;
    border-bottom: 1px solid #e4e7ed;
    height: 48px;

    i {
      margin-right: 8px;
      color: #909399;
    }
  }

  ::v-deep .el-collapse-item__content {
    padding: 16px;
    background: #ffffff;
  }
}

// 操作按钮区域
.form-actions {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 32px;
  padding: 20px;
  background: white;
  border-radius: 8px;
  border: 1px solid #f0f0f0;

  .generate-btn {
    background: #409eff;
    border-color: #409eff;
    padding: 10px 28px;
    font-weight: 500;
    transition: all 0.2s;

    &:hover {
      background: #66b1ff;
      border-color: #66b1ff;
      transform: translateY(-1px);
      box-shadow: 0 2px 8px rgba(64, 158, 255, 0.3);
    }

    &:active {
      transform: translateY(0);
    }

    &:disabled {
      background: #c0c4cc;
      border-color: #c0c4cc;
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
      border-color: #f56c6c;
    }
  }
}

// 进度提示
.progress-hint {
  margin-top: 24px;
  padding: 16px;
  background: #f9f9f9;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  text-align: center;

  .hint-text {
    margin-top: 12px;
    color: #909399;
    font-size: 14px;
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

  .selected-game-content {
    flex-direction: column;

    .game-icon {
      margin-right: 0;
      margin-bottom: 12px;
    }
  }

  .form-actions {
    flex-direction: column;
    gap: 12px;
    padding: 16px;

    button {
      width: 100%;
    }
  }

  .count-tips {
    flex-wrap: wrap;
    justify-content: center;
  }
}

// 美化El-Alert
::v-deep .el-alert {
  border-radius: 6px;
  border: 1px solid #ebeef5;
  margin-bottom: 20px;

  &.el-alert--info {
    background-color: #f4f4f5;
    color: #909399;

    .el-alert__icon {
      color: #909399;
    }
  }

  .el-alert__title {
    font-weight: 500;
    font-size: 14px;
  }

  .el-alert__content {
    p {
      margin: 4px 0;
      font-size: 13px;
      line-height: 1.5;
    }
  }
}

.mb-20 {
  margin-bottom: 20px;
}

// 优化按钮组
::v-deep .el-button {
  border-radius: 6px;

  &--medium {
    padding: 10px 20px;
    font-size: 14px;
  }

  &.is-plain {
    &:hover {
      background: #ecf5ff;
      border-color: #c6e2ff;
      color: #409eff;
    }
  }
}

// 加载动画
@keyframes pulse {
  0% {
    opacity: 1;
  }

  50% {
    opacity: 0.5;
  }

  100% {
    opacity: 1;
  }
}

.game-search-input {
  ::v-deep .el-loading-mask {
    .el-loading-spinner {
      .circular {
        animation: pulse 1.5s ease-in-out infinite;
      }
    }
  }
}
</style>
