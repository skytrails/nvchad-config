<!-- 详情弹窗 -->
<template>
  <el-dialog title="详情" width="700px" :visible="visible" :lock-scroll="false" :destroy-on-close="true"
    @update:visible="updateVisible">
    <el-form size="mini" label-width="82px" class="ele-form-detail">
      <el-row :gutter="15">
        <el-col :sm="12">
          <el-form-item label="操作用户:">
            <div class="ele-text-secondary">
              {{ data.operName }}
            </div>
          </el-form-item>
          <el-form-item label="操作模块:">
            <div class="ele-text-secondary">
              {{ data.title }}
            </div>
          </el-form-item>
          <el-form-item label="操作时间:">
            <div class="ele-text-secondary">
              {{ new Date(data.createdAt) | toDateString }}
            </div>
          </el-form-item>
          <el-form-item label="操作方式:">
            <div class="ele-text-secondary">
              {{ data.requestMethod }}
            </div>
          </el-form-item>
        </el-col>
        <el-col :sm="12">
          <el-form-item label="操作IP:">
            <div class="ele-text-secondary">
              {{ data.operIp }}
            </div>
          </el-form-item>
          <el-form-item label="操作类型:">
            <div class="ele-text-secondary">
              <el-tag :type="['success', 'danger', 'warning', 'info'][data.operType]" size="mini">
                {{ ['其他', '新增', '修改', '删除', '导出数据', '登录', '登出'][data.operType] }}
              </el-tag>
            </div>
          </el-form-item>
          <el-form-item label="操作状态:">
            <el-tag :type="['success', 'danger'][data.status]" size="mini">
              {{ ['操作成功', '操作失败'][data.status] }}
            </el-tag>
          </el-form-item>
        </el-col>
      </el-row>
      <div style="margin: 12px 0;">
        <el-divider />
      </div>
      <el-form-item label="请求地址:">
        <div class="ele-text-secondary">
          {{ data.operUrl }}
        </div>
      </el-form-item>
      <el-form-item label="调用方法:">
        <div class="ele-text-secondary">
          {{ data.operMethod }}
        </div>
      </el-form-item>
      <el-form-item label="请求参数:">
        <div class="ele-text-secondary">
          {{ data.operParam }}
        </div>
      </el-form-item>
      <el-form-item label="操作结果:">
        <div class="ele-text-secondary">
          {{ data.jsonResult }}
        </div>
      </el-form-item>
    </el-form>
    <div slot="footer">
      <el-button @click="updateVisible(false)">关闭
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: 'OperRecordDetail',
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 数据
    data: Object
  },
  methods: {
    /* 更新visible */
    updateVisible(value) {
      this.$emit('update:visible', value);
    }
  }
}
</script>

<style scoped></style>
