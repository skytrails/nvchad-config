<template>
  <div class="config-web-container">
    <!-- 顶部装饰性背景 -->
    <div class="top-decoration">
      <div class="decoration-circle circle-1"></div>
      <div class="decoration-circle circle-2"></div>
      <div class="decoration-circle circle-3"></div>
    </div>

    <el-card shadow="never" class="config-card" body-style="padding: 0;">
      <!-- 卡片头部 -->
      <div class="card-header">
        <div class="header-left">
          <i class="el-icon-setting header-icon"></i>
          <div>
            <h2 style="color: white;">系统配置管理</h2>
            <p class="header-desc">根据业务需求调整系统参数和功能设置</p>
          </div>
        </div>
        <div class="header-right">
          <el-tag type="success" effect="dark">
            <i class="el-icon-info"></i>
            配置实时生效
          </el-tag>
        </div>
      </div>

      <!-- Tab导航 -->
      <div class="tab-container">
        <el-tabs v-model="active" @tab-click="handleClick">
          <el-tab-pane v-for="(item, index) in configList" :key="index" :name="'tab_' + index">
            <template #label>
              <div class="tab-label">
                <i :class="getTabIcon(item.configName)"></i>
                <span>{{ item.configName }}</span>
                <el-badge v-if="getConfigCount(item.dataList) > 0" :value="getConfigCount(item.dataList)"
                  class="tab-badge" />
              </div>
            </template>

            <!-- 配置内容区域 -->
            <div class="tab-content">
              <div class="content-header">
                <h3>{{ item.configName }}配置</h3>
                <el-button type="text" @click="showAdvanced = !showAdvanced" class="advanced-toggle">
                  <i :class="showAdvanced ? 'el-icon-arrow-up' : 'el-icon-arrow-down'"></i>
                  {{ showAdvanced ? '收起高级设置' : '显示高级设置' }}
                </el-button>
              </div>

              <!-- 配置表单 -->
              <div class="config-form-container">
                <div class="config-stats" v-if="item.dataList && item.dataList.length > 0">
                  <div class="stat-item">
                    <i class="el-icon-document"></i>
                    <span>{{ item.dataList.length }} 个配置项</span>
                  </div>
                  <div class="stat-item">
                    <i class="el-icon-time"></i>
                    <span>最后更新: {{ lastUpdated }}</span>
                  </div>
                </div>

                <div class="form-scroll-area">
                  <el-form :model="form" ref="form" label-width="180px" label-position="right" class="config-form">
                    <div v-for="(subItem, val) in item.dataList" :key="val" class="form-item-wrapper" :class="{
                      'advanced-item': subItem.advanced,
                      'highlight-item': shouldHighlight(subItem)
                    }">
                      <!-- 配置项标签 -->
                      <div class="config-item-header">
                        <el-tooltip :content="subItem.description || subItem.title" placement="top"
                          v-if="subItem.description">
                          <i class="el-icon-question config-help"></i>
                        </el-tooltip>
                        <span class="config-index">#{{ val + 1 }}</span>
                      </div>

                      <!-- 不同类型的输入组件 -->
                      <div class="config-item-content">
                        <!-- 单行文本框 -->
                        <el-form-item v-if="subItem.type == 'text'" :label="subItem.title + ':'" :prop="subItem.code">
                          <div class="input-with-action">
                            <el-input v-model="form[subItem.code]" :placeholder="'请输入' + subItem.title" clearable
                              size="medium" class="animated-input" />
                            <el-button v-if="subItem.example" type="text" size="mini"
                              @click="applyExample(subItem.code, subItem.example)" class="example-btn">
                              使用示例
                            </el-button>
                          </div>
                          <div class="config-hint" v-if="subItem.hint">
                            <i class="el-icon-info"></i>
                            {{ subItem.hint }}
                          </div>
                        </el-form-item>

                        <!-- 多行文本框 -->
                        <el-form-item v-if="subItem.type == 'textarea'" :label="subItem.title + ':'"
                          :prop="subItem.code">
                          <el-input v-model="form[subItem.code]" :placeholder="'请输入' + subItem.title" :rows="4"
                            type="textarea" resize="vertical" maxlength="500" show-word-limit
                            class="animated-textarea" />
                        </el-form-item>

                        <!-- 单图上传 -->
                        <el-form-item v-if="subItem.type == 'image'" :label="subItem.title + ':'">
                          <div class="upload-card">
                            <uploadImage :limit="1" :updDir="updDir" v-model="form[subItem.code]"
                              class="custom-upload" />
                            <div class="upload-tips" v-if="subItem.tips">
                              {{ subItem.tips }}
                            </div>
                          </div>
                        </el-form-item>

                        <!-- 多图上传 -->
                        <el-form-item v-if="subItem.type == 'images'" :label="subItem.title + ':'">
                          <uploadImage :limit="10" :updDir="updDir" v-model="form[subItem.code]"
                            class="custom-upload-multi" />
                        </el-form-item>

                        <!-- 日期选择 -->
                        <el-form-item v-if="subItem.type == 'date'" :label="subItem.title + ':'" :prop="subItem.code">
                          <el-date-picker v-model="form[subItem.code]" type="date" :placeholder="'请选择' + subItem.title"
                            value-format="yyyy-MM-dd" format="yyyy-MM-dd" class="date-picker">
                          </el-date-picker>
                        </el-form-item>

                        <!-- 日期时间选择 -->
                        <el-form-item v-if="subItem.type == 'datetime'" :label="subItem.title + ':'"
                          :prop="subItem.code">
                          <el-date-picker v-model="form[subItem.code]" type="datetime"
                            :placeholder="'请选择' + subItem.title" value-format="yyyy-MM-dd HH:mm:ss"
                            format="yyyy-MM-dd HH:mm:ss" class="datetime-picker">
                          </el-date-picker>
                        </el-form-item>

                        <!-- 单选按钮 -->
                        <el-form-item v-if="subItem.type == 'radio'" :label="subItem.title + ':'">
                          <el-radio-group v-model="form[subItem.code]" class="radio-group">
                            <el-radio v-for="(val, key) in subItem.param" :label="key" :key="val" class="custom-radio">
                              <span class="radio-label">{{ val }}</span>
                            </el-radio>
                          </el-radio-group>
                        </el-form-item>

                        <!-- 数字输入框 -->
                        <el-form-item v-if="subItem.type == 'number'" :label="subItem.title + ':'" :prop="subItem.code">
                          <el-input-number v-model="form[subItem.code]" controls-position="right"
                            :min="subItem.min || 0" :max="subItem.max || 99999" :step="subItem.step || 1"
                            :placeholder="'请输入' + subItem.title" class="custom-number-input" />
                          <span class="unit-text" v-if="subItem.unit">{{ subItem.unit }}</span>
                        </el-form-item>

                        <!-- 密码输入框 -->
                        <el-form-item v-if="subItem.type == 'password'" :label="subItem.title + ':'"
                          :prop="subItem.code">
                          <el-input v-model="form[subItem.code]" :placeholder="'请输入' + subItem.title" show-password
                            class="password-input" />
                        </el-form-item>

                        <!-- 复选框 -->
                        <el-form-item v-if="subItem.type == 'checkbox'" :label="subItem.title + ':'"
                          :prop="subItem.code">
                          <el-checkbox-group v-model="form[subItem.code]" class="checkbox-group">
                            <el-checkbox v-for="(val, key) in subItem.param" :label="key" :key="val"
                              class="custom-checkbox">
                              {{ val }}
                            </el-checkbox>
                          </el-checkbox-group>
                        </el-form-item>

                        <!-- 下拉单选框 -->
                        <el-form-item v-if="subItem.type == 'select'" :label="subItem.title + ':'" :prop="subItem.code">
                          <el-select v-model="form[subItem.code]" :placeholder="'请选择' + subItem.title" clearable
                            class="custom-select">
                            <el-option v-for="(val, key) in subItem.param" :label="val" :value="key" :key="key"
                              class="select-option" />
                          </el-select>
                        </el-form-item>

                        <!-- 富文本编辑器 -->
                        <el-form-item v-if="subItem.type == 'ueditor'" :label="subItem.title + ':'">
                          <div class="editor-wrapper">
                            <tinymce-editor v-model="form[subItem.code]" :init="initEditor" class="custom-editor" />
                            <div class="editor-tips">
                              <i class="el-icon-edit"></i>
                              支持图文混排，建议使用清晰图片
                            </div>
                          </div>
                        </el-form-item>

                        <!-- 图标选择 -->
                        <el-form-item v-if="subItem.type == 'icon'" :label="subItem.title + ':'">
                          <ele-icon-picker v-model="form[subItem.code]" :placeholder="'请选择' + subItem.title"
                            class="icon-picker" />
                        </el-form-item>
                      </div>
                    </div>
                  </el-form>
                </div>

                <!-- 操作按钮区域 -->
                <div class="action-buttons">
                  <el-button type="default" @click="resetForm" class="reset-btn">
                    <i class="el-icon-refresh"></i>
                    恢复默认
                  </el-button>
                  <el-button type="primary" @click="save" :loading="loading" class="save-btn">
                    <i class="el-icon-check"></i>
                    {{ loading ? '保存中...' : '保存配置' }}
                  </el-button>
                  <el-button type="success" @click="testConfig" v-if="hasTestFunction" class="test-btn">
                    <i class="el-icon-video-play"></i>
                    测试配置
                  </el-button>
                </div>
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
    </el-card>

    <!-- 配置预览悬浮按钮 -->
    <el-tooltip content="预览配置" placement="left">
      <el-button type="info" circle class="preview-btn" @click="showPreview">
        <i class="el-icon-view"></i>
      </el-button>
    </el-tooltip>
  </div>
</template>

<script>
import uploadImage from '@/components/uploadImage'
import TinymceEditor from '@/components/TinymceEditor'

export default {
  name: "ConfigWeb",
  components: { uploadImage, TinymceEditor },
  data() {
    return {
      active: 'tab_0',
      loading: false,
      form: {},
      configList: [],
      updDir: 'config',
      showAdvanced: false,
      lastUpdated: '刚刚',
      hasTestFunction: false
    }
  },
  computed: {
    initEditor() {
      return {
        height: 400,
        file_picker_callback: this.file_picker_callback,
        skin_url: this.$store.state.theme.theme === 'dark' ? '/tinymce/skins/ui/oxide-dark' : '/tinymce/skins/ui/oxide',
        content_css: this.$store.state.theme.theme === 'dark' ? '/tinymce/skins/content/dark/content.css' : '/tinymce/skins/content/default/content.css',
        images_upload_handler: (blobInfo, success, error) => {
          let file = blobInfo.blob();
          const formData = new FormData();
          formData.append('file', file, file.name);
          this.$http.post('/upload/uploadImage', formData).then(res => {
            if (res.data.code == 0) {
              success(res.data.data);
            } else {
              error(res.data.msg);
            }
          }).catch(e => {
            console.error(e);
            error(e.message);
          });
        }
      };
    }
  },
  mounted() {
    this.getConfigInfo();
    this.updateTime();
  },
  methods: {
    getTabIcon(tabName) {
      const iconMap = {
        '基本': 'el-icon-house',
        '系统': 'el-icon-setting',
        '安全': 'el-icon-lock',
        '邮件': 'el-icon-message',
        '短信': 'el-icon-chat-dot-round',
        '支付': 'el-icon-money',
        '存储': 'el-icon-folder',
        '其他': 'el-icon-more'
      };
      return iconMap[tabName] || 'el-icon-setting';
    },

    getConfigCount(dataList) {
      return dataList ? dataList.length : 0;
    },

    shouldHighlight(subItem) {
      return subItem.important || subItem.required;
    },

    applyExample(code, example) {
      this.form[code] = example;
      this.$message.success('已应用示例值');
    },

    resetForm() {
      this.$confirm('确定要恢复默认配置吗？', '提示', {
        type: 'warning',
        confirmButtonText: '确定',
        cancelButtonText: '取消'
      }).then(() => {
        this.getConfigInfo();
        this.$message.success('已恢复默认配置');
      });
    },

    testConfig() {
      // 测试配置功能
      this.$message.info('测试功能开发中...');
    },

    showPreview() {
      this.$message.info('配置预览功能开发中...');
    },

    updateTime() {
      const now = new Date();
      this.lastUpdated = now.toLocaleTimeString('zh-CN', {
        hour12: false,
        hour: '2-digit',
        minute: '2-digit'
      });
    },

    getConfigInfo() {
      this.$http.get('/config/list').then(res => {
        if (res.data.code === 200) {
          this.configList = res.data.data;
          if (this.configList.length > 0) {
            let itemList = this.configList[0]['dataList'];
            let itemArr = {};
            itemList.forEach(item => {
              if (item.valueList) {
                itemArr[item.code] = item.valueList;
              } else {
                itemArr[item.code] = item.value;
              }
            })
            this.form = itemArr;
          } else {
            this.form = {};
          }
        }
      }).catch(e => {
        this.form = {}
        this.$message.error(e.message);
      });
    },

    save() {
      this.loading = true;
      this.$http.put('/configweb/edit', this.form).then(res => {
        this.loading = false;
        if (res.data.code === 0) {
          this.$message.success({
            message: res.data.msg,
            duration: 2000,
            showClose: true
          });
          this.updateTime();
        } else {
          this.$message.error(res.data.msg);
        }
      }).catch(e => {
        this.loading = false;
        this.$message.error(e.message);
      });
    },

    handleClick(tab) {
      let itemList = this.configList[tab.index]['dataList'];
      let itemArr = {};
      itemList.forEach(item => {
        if (item.valueList) {
          itemArr[item.code] = item.valueList;
        } else {
          itemArr[item.code] = item.value;
        }
      })
      this.form = itemArr;
    }
  }
}
</script>

<style scoped>
.config-web-container {
  position: relative;
  min-height: calc(100vh - 120px);
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 20px;
}

/* 装饰性背景 */
.top-decoration {
  position: absolute;
  top: 0;
  right: 0;
  width: 400px;
  height: 400px;
  overflow: hidden;
  pointer-events: none;
}

.decoration-circle {
  position: absolute;
  border-radius: 50%;
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.1) 0%, rgba(103, 194, 58, 0.1) 100%);
}

.circle-1 {
  width: 200px;
  height: 200px;
  top: -100px;
  right: -50px;
}

.circle-2 {
  width: 150px;
  height: 150px;
  top: 50px;
  right: 100px;
}

.circle-3 {
  width: 100px;
  height: 100px;
  top: 150px;
  right: 250px;
}

/* 卡片样式 */
.config-card {
  border-radius: 12px !important;
  border: none;
  position: relative;
  z-index: 1;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.1) !important;
}

/* 卡片头部 */
.card-header {
  padding: 24px 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 12px 12px 0 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-icon {
  font-size: 32px;
  background: rgba(255, 255, 255, 0.2);
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.header-left h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.header-desc {
  margin: 4px 0 0;
  opacity: 0.9;
  font-size: 14px;
}

/* Tab容器 */
.tab-container {
  padding: 0 20px;
}

:deep(.el-tabs__nav-wrap::after) {
  height: 1px;
  background: linear-gradient(90deg, transparent, #e4e7ed, transparent);
}

:deep(.el-tabs__active-bar) {
  background: linear-gradient(90deg, #667eea, #764ba2);
  height: 3px;
  border-radius: 3px;
}

:deep(.el-tabs__item) {
  font-size: 15px;
  font-weight: 500;
  color: #606266;
  padding: 0 20px;
  height: 50px;
  line-height: 50px;
}

:deep(.el-tabs__item.is-active) {
  color: #667eea;
  font-weight: 600;
}

:deep(.el-tabs__item:hover) {
  color: #764ba2;
}

.tab-label {
  display: flex;
  align-items: center;
  gap: 8px;
  position: relative;
}

.tab-badge {
  position: absolute;
  top: -5px;
  right: -15px;
}

/* Tab内容区 */
.tab-content {
  padding: 20px 0;
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #ebeef5;
}

.content-header h3 {
  margin: 0;
  font-size: 18px;
  color: #303133;
  font-weight: 600;
}

.advanced-toggle {
  color: #409eff;
  font-size: 14px;
}

/* 配置统计 */
.config-stats {
  display: flex;
  gap: 24px;
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #409eff;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #606266;
  font-size: 14px;
}

.stat-item i {
  color: #409eff;
  font-size: 16px;
}

/* 表单滚动区域 */
.form-scroll-area {
  max-height: 600px;
  overflow-y: auto;
  padding-right: 10px;
}

.form-scroll-area::-webkit-scrollbar {
  width: 6px;
}

.form-scroll-area::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.form-scroll-area::-webkit-scrollbar-thumb {
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 3px;
}

/* 表单容器 */
.config-form {
  padding: 16px;
}

.form-item-wrapper {
  margin-bottom: 24px;
  padding: 20px;
  background: white;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  transition: all 0.3s ease;
  position: relative;
}

.form-item-wrapper:hover {
  border-color: #409eff;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.1);
  transform: translateY(-2px);
}

.form-item-wrapper.highlight-item {
  border-left: 4px solid #f56c6c;
  background: linear-gradient(90deg, rgba(245, 108, 108, 0.05) 0%, rgba(255, 255, 255, 1) 100%);
}

.form-item-wrapper.advanced-item {
  border-left: 4px solid #e6a23c;
  background: linear-gradient(90deg, rgba(230, 162, 60, 0.05) 0%, rgba(255, 255, 255, 1) 100%);
}

/* 配置项头部 */
.config-item-header {
  position: absolute;
  top: 10px;
  right: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.config-help {
  color: #909399;
  cursor: help;
  font-size: 16px;
}

.config-index {
  font-size: 12px;
  color: #c0c4cc;
  font-weight: 500;
}

/* 配置项内容 */
.config-item-content {
  margin-top: 8px;
}

:deep(.el-form-item__label) {
  font-weight: 500;
  color: #303133;
  padding-right: 20px;
}

.input-with-action {
  display: flex;
  gap: 12px;
  align-items: center;
}

.example-btn {
  white-space: nowrap;
}

.config-hint {
  margin-top: 6px;
  font-size: 12px;
  color: #909399;
  display: flex;
  align-items: center;
  gap: 4px;
}

/* 上传组件样式 */
.upload-card {
  border: 1px dashed #dcdfe6;
  border-radius: 6px;
  padding: 16px;
  background: #fafafa;
  transition: all 0.3s;
}

.upload-card:hover {
  border-color: #409eff;
  background: rgba(64, 158, 255, 0.02);
}

.upload-tips {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}

/* 日期选择器样式 */
.date-picker,
.datetime-picker {
  width: 100%;
}

/* 单选和复选框样式 */
.radio-group,
.checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.custom-radio,
.custom-checkbox {
  margin-right: 0 !important;
}

.radio-label {
  padding: 4px 8px;
}

/* 数字输入框 */
.custom-number-input {
  width: 200px;
}

.unit-text {
  margin-left: 8px;
  color: #606266;
  font-size: 14px;
}

/* 选择器样式 */
.custom-select {
  width: 100%;
}

.select-option:hover {
  background: linear-gradient(90deg, #667eea, #764ba2) !important;
  color: white !important;
}

/* 富文本编辑器 */
.editor-wrapper {
  border: 1px solid #dcdfe6;
  border-radius: 6px;
  overflow: hidden;
}

.editor-tips {
  padding: 8px 12px;
  background: #f0f9ff;
  border-top: 1px solid #e4e7ed;
  font-size: 12px;
  color: #409eff;
  display: flex;
  align-items: center;
  gap: 6px;
}

/* 图标选择器 */
.icon-picker {
  width: 100%;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #ebeef5;
}

.reset-btn,
.save-btn,
.test-btn {
  min-width: 120px;
  height: 40px;
  border-radius: 6px;
  font-weight: 500;
}

.save-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  border: none !important;
}

.save-btn:hover {
  opacity: 0.9;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

/* 预览按钮 */
.preview-btn {
  position: fixed;
  right: 40px;
  bottom: 40px;
  width: 56px;
  height: 56px;
  font-size: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  z-index: 1000;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {

  0%,
  100% {
    transform: translateY(0);
  }

  50% {
    transform: translateY(-10px);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .config-web-container {
    padding: 10px;
  }

  .card-header {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }

  .tab-container {
    padding: 0 10px;
  }

  .config-stats {
    flex-direction: column;
    gap: 12px;
  }

  .action-buttons {
    flex-direction: column;
    gap: 12px;
  }

  .reset-btn,
  .save-btn,
  .test-btn {
    width: 100%;
  }
}

/* 深色模式适配 */
@media (prefers-color-scheme: dark) {
  .config-web-container {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  }

  .config-card {
    background: rgba(30, 30, 46, 0.95);
    color: #e4e7ed;
  }

  .form-item-wrapper {
    background: #2d3748;
    border-color: #4a5568;
  }

  .form-item-wrapper:hover {
    border-color: #667eea;
  }

  .config-stats {
    background: #2d3748;
  }

  .upload-card {
    background: #2d3748;
    border-color: #4a5568;
  }
}
</style>
