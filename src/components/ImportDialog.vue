<!-- src/views/system/user/import-dialog.vue -->
<template>
  <el-dialog
    title="导入用户"
    :visible.sync="visible"
    width="800px"
    @close="handleClose"
    class="import-dialog"
  >
    <div class="import-steps">
      <el-steps :active="activeStep" align-center>
        <el-step title="选择文件" description="上传Excel文件" />
        <el-step title="预览数据" description="确认导入数据" />
        <el-step title="导入结果" description="查看导入结果" />
      </el-steps>
    </div>

    <!-- 步骤1：选择文件 -->
    <div v-show="activeStep === 0" class="step-content">
      <div class="upload-section">
        <el-upload
          ref="upload"
          class="upload-demo"
          drag
          :action="uploadUrl"
          :headers="headers"
          :data="uploadData"
          :on-success="handleSuccess"
          :on-error="handleError"
          :before-upload="beforeUpload"
          :show-file-list="false"
          :accept="'.xlsx, .xls'"
        >
          <div class="upload-area">
            <i class="el-icon-upload upload-icon"></i>
            <div class="upload-text">
              <div class="upload-title">点击或拖拽文件到此处上传</div>
              <div class="upload-tips">支持 .xlsx, .xls 格式文件，大小不超过10MB</div>
            </div>
          </div>
        </el-upload>

        <div class="template-section">
          <div class="template-header">
            <i class="el-icon-download"></i>
            <span>下载模板</span>
          </div>
          <div class="template-buttons">
            <el-button
              type="text"
              @click="downloadTemplate('simple')"
              class="template-btn"
            >
              简单模板
            </el-button>
            <el-button
              type="text"
              @click="downloadTemplate('full')"
              class="template-btn"
            >
              完整模板
            </el-button>
          </div>
          <div class="template-tips">
            请按照模板格式填写数据，红色字段为必填项
          </div>
        </div>
      </div>

      <div class="import-rules">
        <el-collapse v-model="activeRules">
          <el-collapse-item title="导入规则说明" name="rules">
            <div class="rules-content">
              <div class="rule-item">
                <el-tag type="danger" size="small">必填项</el-tag>
                <span>用户账号、密码、姓名、手机号</span>
              </div>
              <div class="rule-item">
                <el-tag type="warning" size="small">格式要求</el-tag>
                <span>手机号必须为11位数字，邮箱需符合格式规范</span>
              </div>
              <div class="rule-item">
                <el-tag type="info" size="small">可选字段</el-tag>
                <span>性别、邮箱、地址、简介等字段可留空</span>
              </div>
              <div class="rule-item">
                <el-tag type="success" size="small">数据校验</el-tag>
                <span>系统会自动校验数据格式和唯一性</span>
              </div>
            </div>
          </el-collapse-item>
        </el-collapse>
      </div>
    </div>

    <!-- 步骤2：预览数据 -->
    <div v-show="activeStep === 1" class="step-content">
      <div class="preview-header">
        <div class="preview-title">
          数据预览（共 {{ previewData.length }} 条）
        </div>
        <div class="preview-actions">
          <el-button
            size="small"
            @click="activeStep = 0"
          >
            重新选择
          </el-button>
        </div>
      </div>

      <div class="preview-table">
        <el-table
          :data="previewData"
          height="300"
          border
          size="small"
          class="preview-data-table"
        >
          <el-table-column
            v-for="col in previewColumns"
            :key="col.prop"
            :prop="col.prop"
            :label="col.label"
            :width="col.width"
            align="center"
          />
        </el-table>
      </div>

      <div class="preview-summary">
        <div class="summary-item">
          <span class="summary-label">有效数据：</span>
          <span class="summary-value valid">{{ validCount }} 条</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">重复数据：</span>
          <span class="summary-value duplicate">{{ duplicateCount }} 条</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">异常数据：</span>
          <span class="summary-value error">{{ errorCount }} 条</span>
        </div>
      </div>

      <div class="preview-errors" v-if="errors.length > 0">
        <el-alert
          title="数据异常提示"
          type="error"
          :closable="false"
          show-icon
        >
          <ul class="error-list">
            <li v-for="(error, index) in errors" :key="index">
              第{{ error.row }}行：{{ error.message }}
            </li>
          </ul>
        </el-alert>
      </div>
    </div>

    <!-- 步骤3：导入结果 -->
    <div v-show="activeStep === 2" class="step-content">
      <div class="result-section">
        <div class="result-icon" :class="resultType">
          <i :class="resultIcon"></i>
        </div>
        <div class="result-title">{{ resultTitle }}</div>
        <div class="result-message">{{ resultMessage }}</div>

        <div class="result-stats">
          <el-row :gutter="20">
            <el-col :span="8">
              <div class="stat-card success">
                <div class="stat-number">{{ importResult.success || 0 }}</div>
                <div class="stat-label">成功导入</div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-card warning">
                <div class="stat-number">{{ importResult.duplicate || 0 }}</div>
                <div class="stat-label">重复数据</div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-card error">
                <div class="stat-number">{{ importResult.error || 0 }}</div>
                <div class="stat-label">失败数据</div>
              </div>
            </el-col>
          </el-row>
        </div>

        <div class="result-actions">
          <el-button
            v-if="importResult.failList && importResult.failList.length > 0"
            type="warning"
            icon="el-icon-download"
            @click="downloadFailList"
          >
            下载失败列表
          </el-button>
          <el-button
            type="primary"
            @click="handleComplete"
          >
            完成
          </el-button>
        </div>
      </div>
    </div>

    <div slot="footer" class="dialog-footer" v-if="activeStep !== 2">
      <el-button @click="handleClose">取消</el-button>
      <el-button
        v-if="activeStep === 1"
        type="primary"
        :loading="importing"
        @click="handleImport"
      >
        {{ importing ? '导入中...' : '确认导入' }}
      </el-button>
      <el-button
        v-if="activeStep === 0 && previewData.length > 0"
        type="primary"
        @click="activeStep = 1"
      >
        下一步
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: 'ImportDialog',

  props: {
    visible: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      activeStep: 0,
      activeRules: ['rules'],
      uploading: false,
      importing: false,
      uploadUrl: '/api/user/import/upload',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token') || ''}`
      },
      uploadData: {
        type: 'user'
      },
      previewData: [],
      previewColumns: [
        { prop: 'username', label: '用户账号', width: 120 },
        { prop: 'password', label: '密码', width: 100 },
        { prop: 'realname', label: '姓名', width: 100 },
        { prop: 'gender', label: '性别', width: 80 },
        { prop: 'mobile', label: '手机号', width: 120 },
        { prop: 'email', label: '邮箱', width: 150 },
        { prop: 'status', label: '状态', width: 80 }
      ],
      errors: [],
      importResult: {},
      resultType: 'success',
      resultIcon: 'el-icon-success',
      resultTitle: '导入成功',
      resultMessage: ''
    };
  },

  computed: {
    validCount() {
      return this.previewData.filter(item => item._valid).length;
    },

    duplicateCount() {
      return this.previewData.filter(item => item._duplicate).length;
    },

    errorCount() {
      return this.previewData.filter(item => item._error).length;
    }
  },

  methods: {
    /* 上传前校验 */
    beforeUpload(file) {
      const isExcel = /\.(xlsx|xls)$/i.test(file.name);
      const isLt10M = file.size / 1024 / 1024 < 10;

      if (!isExcel) {
        this.$message.error('只能上传Excel文件!');
        return false;
      }

      if (!isLt10M) {
        this.$message.error('文件大小不能超过10MB!');
        return false;
      }

      this.uploading = true;
      return true;
    },

    /* 上传成功 */
    handleSuccess(response) {
      this.uploading = false;

      if (response.code === 200) {
        this.previewData = response.data.list || [];
        this.errors = response.data.errors || [];
        this.$message.success('文件上传成功，请预览数据');
      } else {
        this.$message.error(response.message || '文件上传失败');
      }
    },

    /* 上传失败 */
    handleError(err) {
      this.uploading = false;
      this.$message.error('文件上传失败');
      console.error('上传失败:', err);
    },

    /* 下载模板 */
    downloadTemplate(type) {
      let url = '';
      if (type === 'simple') {
        url = '/api/user/import/template/simple';
      } else {
        url = '/api/user/import/template/full';
      }

      const a = document.createElement('a');
      a.href = url;
      a.download = `用户导入模板_${type}.xlsx`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);

      this.$message.success('模板下载开始，请稍候...');
    },

    /* 执行导入 */
    async handleImport() {
      if (this.validCount === 0) {
        this.$message.warning('没有有效数据可以导入');
        return;
      }

      this.importing = true;

      try {
        const response = await this.$http.post('/api/user/import/save', {
          data: this.previewData.filter(item => item._valid)
        });

        this.importing = false;

        if (response.data.code === 200) {
          this.importResult = response.data.data || {};
          this.resultType = 'success';
          this.resultIcon = 'el-icon-success';
          this.resultTitle = '导入完成';
          this.resultMessage = `成功导入 ${this.importResult.success || 0} 条用户数据`;
          this.activeStep = 2;
        } else {
          this.$message.error(response.data.message || '导入失败');
        }
      } catch (error) {
        this.importing = false;
        this.$message.error('导入失败: ' + error.message);
      }
    },

    /* 下载失败列表 */
    downloadFailList() {
      if (!this.importResult.failList || this.importResult.failList.length === 0) {
        this.$message.warning('没有失败数据');
        return;
      }

      // 将失败数据转换为CSV格式
      const csvContent = this.convertToCSV(this.importResult.failList);
      const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');

      link.href = URL.createObjectURL(blob);
      link.download = `用户导入失败列表_${new Date().getTime()}.csv`;
      link.click();
    },

    /* 转换为CSV */
    convertToCSV(data) {
      if (!data || data.length === 0) return '';

      const headers = Object.keys(data[0]);
      const rows = data.map(row =>
        headers.map(header => JSON.stringify(row[header] || '')).join(',')
      );

      return [headers.join(','), ...rows].join('\n');
    },

    /* 完成导入 */
    handleComplete() {
      this.handleClose();
      this.$emit('success');
    },

    /* 关闭弹窗 */
    handleClose() {
      // 重置所有状态
      this.activeStep = 0;
      this.previewData = [];
      this.errors = [];
      this.importResult = {};
      this.uploading = false;
      this.importing = false;

      if (this.$refs.upload) {
        this.$refs.upload.clearFiles();
      }

      this.$emit('update:visible', false);
    }
  }
};
</script>

<style scoped>
.import-dialog ::v-deep .el-dialog__body {
  padding: 20px 24px;
}

.import-steps {
  margin-bottom: 30px;
}

.step-content {
  min-height: 400px;
}

/* 上传区域 */
.upload-section {
  display: flex;
  gap: 30px;
  margin-bottom: 20px;
}

.upload-demo {
  flex: 1;
}

.upload-area {
  padding: 40px 0;
  text-align: center;
}

.upload-icon {
  font-size: 48px;
  color: #c0c4cc;
  margin-bottom: 20px;
}

.upload-title {
  font-size: 16px;
  color: #606266;
  margin-bottom: 8px;
}

.upload-tips {
  font-size: 14px;
  color: #909399;
}

.template-section {
  width: 200px;
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
}

.template-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  color: #606266;
  font-weight: 500;
}

.template-buttons {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 16px;
}

.template-btn {
  justify-content: flex-start;
  padding: 8px 12px;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  background: white;
}

.template-btn:hover {
  border-color: #1890ff;
  color: #1890ff;
}

.template-tips {
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
}

.import-rules {
  margin-top: 20px;
}

.rules-content {
  padding: 16px;
}

.rule-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.rule-item:last-child {
  margin-bottom: 0;
}

/* 预览区域 */
.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.preview-title {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.preview-table {
  margin-bottom: 20px;
}

.preview-data-table {
  border-radius: 4px;
}

.preview-summary {
  display: flex;
  gap: 30px;
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 4px;
}

.summary-item {
  flex: 1;
  text-align: center;
}

.summary-label {
  color: #606266;
}

.summary-value {
  font-weight: 600;
  margin-left: 4px;
}

.summary-value.valid {
  color: #52c41a;
}

.summary-value.duplicate {
  color: #faad14;
}

.summary-value.error {
  color: #ff4d4f;
}

.preview-errors {
  margin-top: 20px;
}

.error-list {
  margin: 8px 0 0 0;
  padding-left: 20px;
  color: #ff4d4f;
}

/* 结果区域 */
.result-section {
  text-align: center;
  padding: 40px 0;
}

.result-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 40px;
  margin-bottom: 20px;
}

.result-icon.success {
  background: #f6ffed;
  color: #52c41a;
  border: 2px solid #b7eb8f;
}

.result-icon.warning {
  background: #fff7e6;
  color: #faad14;
  border: 2px solid #ffd591;
}

.result-icon.error {
  background: #fff2f0;
  color: #ff4d4f;
  border: 2px solid #ffccc7;
}

.result-title {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 12px;
  color: #303133;
}

.result-message {
  font-size: 16px;
  color: #606266;
  margin-bottom: 30px;
}

.result-stats {
  margin: 30px 0;
}

.stat-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.stat-card.success {
  border-top: 4px solid #52c41a;
}

.stat-card.warning {
  border-top: 4px solid #faad14;
}

.stat-card.error {
  border-top: 4px solid #ff4d4f;
}

.stat-number {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 8px;
}

.stat-card.success .stat-number {
  color: #52c41a;
}

.stat-card.warning .stat-number {
  color: #faad14;
}

.stat-card.error .stat-number {
  color: #ff4d4f;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.result-actions {
  margin-top: 30px;
}

/* 对话框底部 */
.dialog-footer {
  text-align: right;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .import-dialog ::v-deep .el-dialog {
    width: 90% !important;
  }

  .upload-section {
    flex-direction: column;
  }

  .template-section {
    width: 100%;
  }

  .preview-summary {
    flex-direction: column;
    gap: 16px;
  }

  .result-stats .el-col {
    margin-bottom: 16px;
  }
}
</style>
