<!-- 文章编辑弹窗 -->
<template>
  <el-drawer
    class="edit-table"
    :title="isUpdate ? '修改游戏' : '添加游戏'"
    :visible.sync="showDrawer"
    :direction="direction"
    :size="drawerSize"
    :before-close="close"
    :wrapperClosable="false"
    :destroy-on-close="true">

    <div class="drawer-container">
      <el-form ref="form" :model="form" :rules="rules" label-width="100px" class="compact-form">
        <el-row :gutter="24">
          <!-- 基础信息区域 -->
          <el-col :xs="24" :sm="12">
            <el-form-item label="游戏ID:" prop="gameId">
              <el-input
                v-model="form.gameId"
                placeholder="请输入游戏ID"
                clearable
                maxlength="200"
                size="medium"
                class="form-input">
                <template slot="prepend">
                  <i class="el-icon-s-promotion"></i>
                </template>
              </el-input>
            </el-form-item>
          </el-col>

          <el-col :xs="24" :sm="12">
            <el-form-item label="游戏名称:" prop="gameName">
              <el-input
                v-model="form.gameName"
                placeholder="请输入游戏名称"
                clearable
                maxlength="200"
                size="medium"
                class="form-input">
                <template slot="prepend">
                  <i class="el-icon-s-opportunity"></i>
                </template>
              </el-input>
            </el-form-item>
          </el-col>

          <!-- 配置状态区域 -->
          <el-col :xs="24">
            <div class="config-card">
              <div class="card-title">
                <i class="el-icon-s-tools"></i>
                <span>配置状态</span>
              </div>
              <div class="config-options">
                <el-checkbox-group v-model="configOptions">
                  <el-checkbox label="D加密" :value="form.denuvo" @change="val => form.denuvo = val">
                    <span class="checkbox-label">D加密</span>
                    <el-tag v-if="form.denuvo" size="mini" type="danger" effect="dark">启用</el-tag>
                  </el-checkbox>
                  <el-checkbox label="DRM" :value="form.drm" @change="val => form.drm = val">
                    <span class="checkbox-label">DRM</span>
                    <el-tag v-if="form.drm" size="mini" type="warning" effect="dark">启用</el-tag>
                  </el-checkbox>
                </el-checkbox-group>
              </div>
            </div>
          </el-col>

          <!-- DRM Stub区域（条件显示） -->
          <el-col v-if="form.drm" :xs="24">
            <div class="drm-card">
              <div class="card-title">
                <i class="el-icon-document"></i>
                <span>DRM Stub配置</span>
                <el-tag size="mini" type="info" style="margin-left: 8px;">高级配置</el-tag>
              </div>
              <el-form-item label="Stub内容:" prop="stub" label-width="120px">
                <el-input
                  type="textarea"
                  v-model="form.stub"
                  :rows="6"
                  placeholder="请输入Stub内容..."
                  maxlength="10000"
                  show-word-limit
                  resize="vertical"
                  class="code-textarea">
                  <template slot="prepend">
                    <i class="el-icon-edit"></i>
                  </template>
                </el-input>
                <div class="textarea-tips">
                  <i class="el-icon-info"></i> 请在此处输入DRM相关的Stub配置信息
                </div>
              </el-form-item>
            </div>
          </el-col>

          <!-- DLC内容区域 -->
          <el-col :xs="24">
            <div class="dlc-card">
              <div class="card-title">
                <i class="el-icon-s-goods"></i>
                <span>DLC内容配置</span>
                <div class="card-tools">
                  <el-tooltip content="每行一个DLC，格式：DLC名称=内容">
                    <i class="el-icon-question"></i>
                  </el-tooltip>
                  <span class="char-count">
                    {{ form.dlcs ? form.dlcs.length : 0 }}/10000
                  </span>
                </div>
              </div>
              <el-form-item label="DLC内容:" prop="dlcs" label-width="120px">
                <el-input
                  type="textarea"
                  v-model="form.dlcs"
                  :rows="8"
                  placeholder="请输入DLC内容，每行一个，格式：DLC名称=内容描述"
                  maxlength="10000"
                  show-word-limit
                  resize="vertical"
                  class="dlc-textarea">
                </el-input>
                <div class="textarea-tips">
                  <i class="el-icon-info"></i> 支持多行输入，每行代表一个独立的DLC配置
                </div>
              </el-form-item>
            </div>
          </el-col>

          <!-- 游戏状态区域 -->
          <el-col :xs="24">
            <div class="status-card">
              <div class="card-title">
                <i class="el-icon-s-flag"></i>
                <span>游戏状态设置</span>
              </div>
              <el-form-item label="状态:" prop="status" label-width="120px">
                <el-radio-group v-model="form.status" class="status-radio">
                  <el-radio :label="1">
                    <el-tag type="success" effect="dark" size="small">
                      <i class="el-icon-check"></i> 生效
                    </el-tag>
                  </el-radio>
                  <el-radio :label="0">
                    <el-tag type="info" effect="dark" size="small">
                      <i class="el-icon-close"></i> 停用
                    </el-tag>
                  </el-radio>
                </el-radio-group>
              </el-form-item>
            </div>
          </el-col>
        </el-row>

        <!-- 操作按钮 -->
        <div class="form-actions">
          <el-button
            type="primary"
            :loading="loading"
            :icon="isUpdate ? 'el-icon-check' : 'el-icon-plus'"
            @click="save"
            size="medium"
            class="save-btn">
            {{ loading ? '保存中...' : isUpdate ? '确认修改' : '确认添加' }}
          </el-button>
          <el-button
            @click="$emit('close')"
            size="medium"
            class="cancel-btn">
            <i class="el-icon-close"></i> 取消返回
          </el-button>
        </div>
      </el-form>
    </div>
  </el-drawer>
</template>

<script>
import "@riophae/vue-treeselect/dist/vue-treeselect.css";

export default {
  name: "EventsEdit",
  props: {
    visible: Boolean,
    data: Object,
    cateList: Array,
  },
  data() {
    return {
      showDrawer: this.visible,
      direction: "rtl",
      drawerSize: this.getDrawerSize(),
      form: Object.assign({
        startAt: "",
        endAt: "",
        gameId: "",
        gameName: "",
        dlcs: "",
        denuvo: false,
        drm: false,
        stub: "",
        status: 1
      }, this.data),
      rules: {
        gameId: [{ required: true, message: "请输入游戏ID", trigger: "blur" }],
        gameName: [
          { required: true, message: "请输入游戏名称", trigger: "blur" },
        ],
        status: [
          { required: true, message: "请选择游戏状态", trigger: "change" },
        ],
      },
      loading: false,
      isUpdate: false,
      updDir: "article",
    };
  },
  computed: {
    configOptions: {
      get() {
        const options = [];
        if (this.form.denuvo) options.push("D加密");
        if (this.form.drm) options.push("DRM");
        return options;
      },
      set(values) {
        this.form.denuvo = values.includes("D加密");
        this.form.drm = values.includes("DRM");
      }
    },
    formDateRange: {
      get() {
        return [this.form.startAt, this.form.endAt];
      },
      set(val) {
        this.form.startAt = val[0];
        this.form.endAt = val[1];
      },
    },
  },
  watch: {
    data() {
      if (this.data && this.data.id) {
        this.form = Object.assign({}, this.data);
        this.isUpdate = true;
      } else {
        this.form = Object.assign({
          startAt: "",
          endAt: "",
          gameId: "",
          gameName: "",
          dlcs: "",
          denuvo: false,
          drm: false,
          stub: "",
          status: 1
        }, this.data);
        this.isUpdate = false;
      }
    },
    visible(val) {
      this.showDrawer = val;
    }
  },
  mounted() {
    this.getInfo();
    window.addEventListener('resize', this.handleResize);
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
  },
  methods: {
    /* 获取文章详情 */
    getInfo() {
      if (this.data && this.data.id > 0) {
        this.$http
          .get("/game/info/" + this.data.id)
          .then((res) => {
            if (res.data.code === 200) {
              this.form = res.data.data;
              this.isUpdate = true;
            } else {
              this.$message.error(res.data.message);
            }
          })
          .catch((e) => {
            this.$message.error(e.message);
          });
      }
    },
    /* 保存编辑 */
    save() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.loading = true;
          this.$http
            .post(this.isUpdate ? "/game/update" : "/cfEvents/add", this.form)
            .then((res) => {
              this.loading = false;
              if (res.data.code === 200) {
                this.$message.success({
                  message: res.data.message,
                  type: 'success',
                  duration: 2000,
                  showClose: true
                });
                if (!this.isUpdate) {
                  this.form = {
                    gameId: "",
                    gameName: "",
                    dlcs: "",
                    denuvo: false,
                    drm: false,
                    stub: "",
                    status: 1
                  };
                }
                this.updateVisible(false);
                this.$emit("done");
              } else {
                this.$message.error(res.data.message);
              }
            })
            .catch((e) => {
              this.loading = false;
              this.$message.error(e.message);
            });
        } else {
          this.$message.warning('请填写完整信息');
          return false;
        }
      });
    },
    /* 更新visible */
    updateVisible(value) {
      this.$emit("update:visible", value);
    },
    /* 关闭页面 */
    close(hide) {
      if (this.loading) {
        this.$message.warning('正在保存，请稍候...');
        return;
      }
      this.$confirm('确定要关闭吗？未保存的内容将会丢失', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
        center: true
      }).then(() => {
        if (hide) {
          hide();
        }
        this.$emit("done");
      }).catch(() => {});
    },
    /* 响应式调整抽屉大小 */
    getDrawerSize() {
      if (window.innerWidth < 768) return '100%';
      if (window.innerWidth < 1200) return '85%';
      return '75%';
    },
    handleResize() {
      this.drawerSize = this.getDrawerSize();
    }
  },
};
</script>

<style scoped>
.drawer-container {
  padding: 20px;
  height: 100%;
  overflow-y: auto;
}

.compact-form {
  max-width: 1200px;
  margin: 0 auto;
}

/* 卡片样式 */
.config-card,
.drm-card,
.dlc-card,
.status-card {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.config-card:hover,
.drm-card:hover,
.dlc-card:hover,
.status-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  border-color: #dcdfe6;
}

.card-title {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid #e9ecef;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
}

.card-title i {
  margin-right: 10px;
  font-size: 18px;
  color: #409EFF;
}

.card-tools {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 10px;
}

.card-tools i {
  color: #909399;
  cursor: pointer;
  font-size: 16px;
}

.char-count {
  color: #909399;
  font-size: 12px;
  background: #fff;
  padding: 2px 8px;
  border-radius: 10px;
  border: 1px solid #dcdfe6;
}

/* 配置选项样式 */
.config-options {
  display: flex;
  gap: 30px;
  flex-wrap: wrap;
}

.checkbox-label {
  margin-right: 8px;
  font-weight: 500;
}

/* 文本域样式 */
.code-textarea,
.dlc-textarea {
  font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
  font-size: 14px;
}

.dlc-textarea :deep(.el-textarea__inner) {
  font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
  line-height: 1.6;
}

.textarea-tips {
  margin-top: 8px;
  color: #909399;
  font-size: 12px;
  display: flex;
  align-items: center;
}

.textarea-tips i {
  margin-right: 6px;
  font-size: 14px;
}

/* 表单输入框样式 */
.form-input :deep(.el-input-group__prepend) {
  background: #f5f7fa;
  border-right: none;
}

.form-input :deep(.el-input__inner) {
  border-left: none;
}

/* 状态单选按钮样式 */
.status-radio {
  display: flex;
  gap: 30px;
}

.status-radio :deep(.el-radio__label) {
  padding-left: 8px;
}

/* 操作按钮样式 */
.form-actions {
  text-align: center;
  margin-top: 40px;
  padding-top: 20px;
  border-top: 1px solid #e9ecef;
}

.save-btn {
  min-width: 120px;
  background: linear-gradient(135deg, #409EFF 0%, #337ecc 100%);
  border: none;
  border-radius: 6px;
  padding: 10px 24px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.save-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(64, 158, 255, 0.25);
}

.save-btn:active {
  transform: translateY(0);
}

.cancel-btn {
  min-width: 100px;
  background: #fff;
  border-color: #dcdfe6;
  color: #606266;
}

.cancel-btn:hover {
  background: #f5f7fa;
  border-color: #c0c4cc;
  color: #303133;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .drawer-container {
    padding: 15px;
  }

  .config-card,
  .drm-card,
  .dlc-card,
  .status-card {
    padding: 15px;
  }

  .card-title {
    font-size: 14px;
  }

  .config-options {
    flex-direction: column;
    gap: 15px;
  }

  .status-radio {
    flex-direction: column;
    gap: 15px;
  }

  .form-actions {
    display: flex;
    flex-direction: column;
    gap: 15px;
  }

  .save-btn,
  .cancel-btn {
    width: 100%;
    margin: 0;
  }
}

@media (max-width: 576px) {
  .drawer-container {
    padding: 10px;
  }

  .config-card,
  .drm-card,
  .dlc-card,
  .status-card {
    padding: 12px;
  }
}
</style>
